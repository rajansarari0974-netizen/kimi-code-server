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

EXPOSE 10000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=3 \
  CMD curl -sf http://localhost:10000/ || exit 1

CMD ["bash", "start.sh"]