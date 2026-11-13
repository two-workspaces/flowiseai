# FlowiseAI for Railway in one service: the official image with SQLite and files on a
# volume, the admin account created at first boot, and a heap sized to the plan.
FROM flowiseai/flowise:3.1.4
USER root
# su-exec runs Flowise as the image's node user after the volume is prepared.
RUN apk add --no-cache su-exec
COPY railway-entrypoint.sh /usr/local/bin/railway-entrypoint.sh
RUN chmod 755 /usr/local/bin/railway-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/railway-entrypoint.sh"]
