# FlowiseAI for Railway in one service: the official image with SQLite and files on a
# volume, the admin account created at first boot, and a heap sized to the plan.
FROM flowiseai/flowise:3.1.4
USER root
# su-exec runs Flowise as the image's node user after the volume is prepared.
RUN apk add --no-cache su-exec
# connect-sqlite3 0.9.17 dropped the filename form of its db option, which Flowise's SQLite
# session store uses ("this.db.exec is not a function" at startup); 0.9.18 restored it.
RUN set -e; cd /tmp && npm pack connect-sqlite3@0.9.18 >/dev/null; \
    for d in $(find /usr/local/lib/node_modules/flowise -type d -path '*/node_modules/connect-sqlite3'); do \
      rm -rf "$d" && mkdir "$d" && tar xzf connect-sqlite3-0.9.18.tgz -C "$d" --strip-components=1 && echo "replaced $d"; \
    done; rm connect-sqlite3-0.9.18.tgz; \
    grep -q '"version": "0.9.18"' /usr/local/lib/node_modules/flowise/node_modules/connect-sqlite3/package.json
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod 755 /usr/local/bin/railway-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
