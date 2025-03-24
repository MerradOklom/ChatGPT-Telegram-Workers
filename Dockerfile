FROM node:20-slim AS build

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN corepack disable && npm install -g pnpm@latest

COPY . /app
WORKDIR /app

RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build:local

FROM node:20-slim AS prod

WORKDIR /app

COPY --from=build /app/packages/apps/local/dist/index.js /app/dist/index.js
COPY --from=build /app/packages/apps/local/package-docker.json /app/package.json

# Create well-formatted config.json with baseURL from environment variable
RUN cat <<EOF > /app/config.json
{
  "database": {
    "type": "local",
    "path": "/app/data.json"
  },
  "server": {
    "hostname": "0.0.0.0",
    "port": 3000,
    "baseURL": ""
  },
  "proxy": "",
  "mode": "webhook"
}
EOF

# Create well-formatted wrangler.toml with environment variables
RUN cat <<EOF > /app/wrangler.toml
name = 'chatgpt-telegram-workers'
workers_dev = true
compatibility_date = "2024-11-11"
compatibility_flags = ["nodejs_compat_v2"]
# Deploy dist
main = './dist/index.js'

[vars]
AI_IMAGE_PROVIDER = "\${AI_IMAGE_PROVIDER}"
AI_PROVIDER = "\${AI_PROVIDER}"
BASE_URL = "\${BASE_URL}"
CHAT_GROUP_WHITE_LIST = "\${CHAT_GROUP_WHITE_LIST}"
CHAT_WHITE_LIST = "\${CHAT_WHITE_LIST}"
DEBUG_MODE = "\${DEBUG_MODE}"
DEV_MODE = "\${DEV_MODE}"
EXTRA_MESSAGE_CONTEXT = "\${EXTRA_MESSAGE_CONTEXT}"
LANGUAGE = "\${LANGUAGE}"
OPENAI_API_BASE = "\${OPENAI_API_BASE}"
OPENAI_API_KEY = "\${OPENAI_API_KEY}"
TELEGRAM_AVAILABLE_TOKENS = "\${TELEGRAM_AVAILABLE_TOKENS}"
TELEGRAM_BOT_NAME = "\${TELEGRAM_BOT_NAME}"
TZ = "\${TZ}"
EOF

RUN npm install
EXPOSE 8787

CMD ["node", "/app/dist/index.js"]
