#!/bin/sh
# Railway entrypoint for FlowiseAI: data on the volume, the admin account made before
# the app is reachable, and a Node heap that fits the service's memory.
set -eu

DATA=/home/node/.flowise
mkdir -p "$DATA/logs" "$DATA/storage"
# Railway mounts the volume owned by root; Flowise runs as node.
[ "$(stat -c %u "$DATA")" = "$(id -u node)" ] || chown -R node:node "$DATA"
chown node:node "$DATA/logs" "$DATA/storage"

export DATABASE_TYPE=sqlite DATABASE_PATH="$DATA" SECRETKEY_PATH="$DATA" \
       LOG_PATH="$DATA/logs" BLOB_STORAGE_PATH="$DATA/storage" STORAGE_TYPE=local
# One proxy (Railway's edge) in front, so client IPs and https are read right.
export NUMBER_OF_PROXIES="${NUMBER_OF_PROXIES:-1}"
[ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ] && export APP_URL="${APP_URL:-https://$RAILWAY_PUBLIC_DOMAIN}"
export DISABLE_FLOWISE_TELEMETRY="${DISABLE_FLOWISE_TELEMETRY:-true}"

# Node sizes its heap from the host's memory, not the container's, so on a small plan it
# grows past the limit and is killed instead of collecting garbage. Use 75% of the limit.
lim=$(cat /sys/fs/cgroup/memory.max 2>/dev/null || echo max)
if [ "$lim" != max ] && [ "$lim" -gt 0 ] 2>/dev/null; then
  heap=$((lim / 1048576 * 3 / 4))
  [ "$heap" -gt 8192 ] && heap=8192
  export NODE_OPTIONS="--max-old-space-size=$heap"
fi

PORT="${PORT:-3000}"
cd /home/node

# First boot: Flowise opens a sign-up page that makes whoever loads it first the
# owner. Start it on a port Railway doesn't route, create the admin from the
# variables, then restart it on the public port.
if [ ! -f "$DATA/.railway-admin" ]; then
  : "${ADMIN_EMAIL:?Set ADMIN_EMAIL (the admin login)}"
  : "${ADMIN_PASSWORD:?Set ADMIN_PASSWORD}"
  echo "First boot: creating the admin account $ADMIN_EMAIL"
  PORT=3999 su-exec node flowise start > /tmp/setup.log 2>&1 &
  pid=$!
  i=0
  until curl -sf http://127.0.0.1:3999/api/v1/ping >/dev/null; do
    i=$((i + 1))
    if [ "$i" -gt 300 ] || ! kill -0 "$pid" 2>/dev/null; then
      echo "Flowise didn't start for setup:"; tail -30 /tmp/setup.log; exit 1
    fi
    sleep 2
  done
  body=$(node -e 'process.stdout.write(JSON.stringify({user:{name:process.env.ADMIN_NAME||"Admin",email:process.env.ADMIN_EMAIL,credential:process.env.ADMIN_PASSWORD}}))')
  code=$(curl -s -o /tmp/register.json -w '%{http_code}' -H 'content-type: application/json' \
         -d "$body" http://127.0.0.1:3999/api/v1/account/register)
  if [ "$code" -lt 300 ]; then
    touch "$DATA/.railway-admin"; chown node:node "$DATA/.railway-admin"
    echo "Admin account created"
  elif grep -q "rganization" /tmp/register.json; then
    # An owner already exists (a volume from an older deploy): nothing to claim.
    touch "$DATA/.railway-admin"; echo "An admin account already exists; leaving it"
  else
    echo "Creating the admin failed ($code): $(cat /tmp/register.json)"
    echo "ADMIN_PASSWORD needs 8+ characters with a lowercase and an uppercase letter, a digit and a symbol."
    kill "$pid"; wait "$pid" 2>/dev/null || true; exit 1
  fi
  kill "$pid"; wait "$pid" 2>/dev/null || true
fi
unset ADMIN_PASSWORD

echo "Flowise on port $PORT${NODE_OPTIONS:+ ($NODE_OPTIONS)}"
exec su-exec node env PORT="$PORT" flowise start
