#!/bin/bash
set -e

# Generate unique token if not set
if [ -z "$KIMI_CODE_PASSWORD" ]; then
    KIMI_CODE_PASSWORD=$(head -c 32 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9' | head -c 32)
    export KIMI_CODE_PASSWORD
fi

# Save the token to a file so user can retrieve it
echo "$KIMI_CODE_PASSWORD" > /app/kimi-token.txt

echo "============================================"
echo "  Kimi Code Server v0.29.1"
echo "  Port: ${PORT:-10000}"
echo "  Token: $KIMI_CODE_PASSWORD"
echo "  URL: http://0.0.0.0:${PORT:-10000}"
echo "============================================"

# Run kimi web directly
exec npx --yes @moonshot-ai/kimi-code web \
    --no-open \
    --port "${PORT:-10000}" \
    --host "0.0.0.0"
