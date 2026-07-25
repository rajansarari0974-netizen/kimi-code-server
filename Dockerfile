FROM node:20-slim

WORKDIR /app

# Install runtime dependencies (curl for health checks, git for setup)
RUN apt-get update -qq && apt-get install -y -qq ca-certificates git curl && rm -rf /var/lib/apt/lists/*

# Copy package files and install
COPY package*.json ./
RUN npm install --production 2>&1 | tail -5

# Pre-cache kimi binary (makes startup faster)
RUN npx --yes @moonshot-ai/kimi-code --version 2>/dev/null || true

# Copy app source
COPY . .

EXPOSE 10000

# docker HEALTHCHECK (informational — Render uses its own)
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -sf http://localhost:${PORT:-10000}/health || exit 1

# Run server.js wrapper — spawns kimi web internally, proxies requests,
# provides /health and /kimi-admin endpoints
CMD ["node", "server.js"]
