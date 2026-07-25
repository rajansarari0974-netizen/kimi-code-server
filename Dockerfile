FROM node:20-slim

WORKDIR /app

# Install runtime dependencies (curl for health checks)
RUN apt-get update -qq && apt-get install -y -qq ca-certificates git curl && rm -rf /var/lib/apt/lists/*

# Copy package files and install
COPY package*.json ./
RUN npm install --production 2>&1 | tail -5

# Pre-cache kimi binary
RUN npx --yes @moonshot-ai/kimi-code --version 2>/dev/null || true

# Copy app source
COPY . .
RUN chmod +x start.sh

# Create entrypoint script that generates token and runs kimi
RUN printf '#!/bin/bash\n\
set -e\n\
KCP="${KIMI_CODE_PASSWORD:-$(head -c 32 /dev/urandom | base64 | tr -dc a-zA-Z0-9 | head -c 32)}"\n\
echo "$KCP" > /app/kimi-token.txt\n\
echo "=== Kimi Code Server ==="\n\
echo "Token: $KCP"\n\
echo "Port: ${PORT:-10000}"\n\
echo "========================"\n\
export KIMI_CODE_PASSWORD="$KCP"\n\
cd /app\n\
if [ -f node_modules/.bin/kimi ]; then\n\
  exec node node_modules/.bin/kimi web --no-open --port "${PORT:-10000}" --host "0.0.0.0" --log-level info\n\
elif [ -f node_modules/@moonshot-ai/kimi-code/dist/main.mjs ]; then\n\
  exec node node_modules/@moonshot-ai/kimi-code/dist/main.mjs web --no-open --port "${PORT:-10000}" --host "0.0.0.0" --log-level info\n\
else\n\
  exec npx --yes @moonshot-ai/kimi-code web --no-open --port "${PORT:-10000}" --host "0.0.0.0" --log-level info\n\
fi\n' > /app/entrypoint.sh && chmod +x /app/entrypoint.sh

EXPOSE 10000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
  CMD curl -sf http://localhost:10000/ || exit 1

CMD ["bash", "/app/entrypoint.sh"]