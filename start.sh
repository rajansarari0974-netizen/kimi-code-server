#!/bin/bash
set -e

# Generate unique token if not set
if [ -z "$KIMI_CODE_PASSWORD" ]; then
    KIMI_CODE_PASSWORD=$(head -c 32 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 32)
    export KIMI_CODE_PASSWORD
fi

# Save token to a file
echo "$KIMI_CODE_PASSWORD" > /app/kimi-token.txt

echo "============================================"
echo "  Kimi Code Server v0.29.1"
echo "  Port: ${PORT:-10000}"
echo "  Token: $KIMI_CODE_PASSWORD"
echo "============================================"

# Find kimi binary
if [ -f "node_modules/.bin/kimi" ]; then
    KIMI_PATH="node_modules/.bin/kimi"
    echo "  Using: local binary (node_modules/.bin/kimi)"
    exec "$KIMI_PATH" web --no-open --port "${PORT:-10000}" --host "0.0.0.0"
elif [ -f "node_modules/@moonshot-ai/kimi-code/dist/main.mjs" ]; then
    KIMI_PATH="node_modules/@moonshot-ai/kimi-code/dist/main.mjs"
    echo "  Using: main.mjs"
    exec node "$KIMI_PATH" web --no-open --port "${PORT:-10000}" --host "0.0.0.0"
elif command -v npx &>/dev/null; then
    echo "  Using: npx"
    exec npx --yes @moonshot-ai/kimi-code web --no-open --port "${PORT:-10000}" --host "0.0.0.0"
else
    echo "ERROR: No kimi binary found!"
    ls -la node_modules/.bin/ 2>/dev/null || echo "(node_modules/.bin not found)"
    ls -la node_modules/@moonshot-ai/ 2>/dev/null || echo "(@moonshot-ai not found)"
    exit 1
fi
