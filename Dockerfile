FROM node:20-slim

WORKDIR /app

# Install runtime dependencies
RUN apt-get update -qq && apt-get install -y -qq ca-certificates git && rm -rf /var/lib/apt/lists/*

# Copy package files and install
COPY package*.json ./
RUN npm install --production 2>&1 | tail -5

# Pre-cache kimi binary for faster startup
RUN npx --yes @moonshot-ai/kimi-code --version 2>/dev/null || true

# Copy app source
COPY . .

# Setup runs at startup from server.js with actual env vars
EXPOSE 10000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD node -e "require('http').get('http://localhost:10000/health', r => process.exit(r.statusCode===200?0:1)).on('error',()=>process.exit(1))"

CMD ["node", "server.js"]