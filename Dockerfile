FROM node:18 AS ninjadev-nin
SHELL ["/bin/bash", "-c"]
RUN npm_config_loglevel=silent npm install --no-fund --no-audit -g ninjadev-nin@v24.0.0

FROM ninjadev-nin AS builder
COPY revision-invite-2018 /app
WORKDIR /app
RUN nin compile --no-closure-compiler --no-tracking \
&&  touch bin/favicon.ico

FROM nginxinc/nginx-unprivileged:mainline-alpine-slim
EXPOSE 8080
COPY --from=builder --chown=nginx:nginx /app/bin/no-invitation.html /usr/share/nginx/html/index.html
COPY --from=builder --chown=nginx:nginx /app/bin/favicon.ico /usr/share/nginx/html/favicon.ico
