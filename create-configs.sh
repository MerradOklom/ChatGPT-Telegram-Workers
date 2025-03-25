#!/bin/bash

# Create config.json with BASE_URL from environment variable (default empty string)
cat <<EOF > /app/config.json
{
  "database": {
    "type": "redis",
    "path": ""
  },
  "server": {
    "hostname": "0.0.0.0",
    "port": 8787,
    "baseURL": "${BASE_URL}"
  },
  "proxy": "",
  "mode": "webhook"
}
EOF

# Create wrangler.toml with environment variables
cat <<EOF > /app/wrangler.toml
name = 'chatgpt-telegram-workers'
workers_dev = true
compatibility_date = "2024-11-11"
compatibility_flags = ["nodejs_compat_v2"]
# Deploy dist
main = './dist/index.js'   # Default use of dist/index.js

[vars]
AI_IMAGE_PROVIDER = "${AI_IMAGE_PROVIDER}"
AI_PROVIDER = "${AI_PROVIDER}"
CHAT_GROUP_WHITE_LIST = "${CHAT_GROUP_WHITE_LIST}"
CHAT_WHITE_LIST = "${CHAT_WHITE_LIST}"
DEBUG_MODE = "${DEBUG_MODE}"
DEV_MODE = "${DEV_MODE}"
EXTRA_MESSAGE_CONTEXT = "${EXTRA_MESSAGE_CONTEXT}"
LANGUAGE = "${LANGUAGE}"
OPENAI_API_BASE = "${OPENAI_API_BASE}"
OPENAI_API_KEY = "${OPENAI_API_KEY}"
TELEGRAM_AVAILABLE_TOKENS = "${TELEGRAM_AVAILABLE_TOKENS}"
TELEGRAM_BOT_NAME = "${TELEGRAM_BOT_NAME}"
TZ = "${TZ}"
MAX_TOKEN_LENGTH = "${MAX_TOKEN_LENGTH}"
STREAM_MODE = "${STREAM_MODE}"
UPSTASH_REDIS_REST_URL = "${UPSTASH_REDIS_REST_URL}"
UPSTASH_REDIS_REST_TOKEN = "${UPSTASH_REDIS_REST_TOKEN}"
EOF
