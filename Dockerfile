# Container definition for hosting this MCP server (Glama and any Docker-based host).
# The server speaks MCP over stdio; no credentials are required (public guest mode).
FROM node:20-alpine

WORKDIR /app

# Install production dependencies from the lockfile so builds are reproducible.
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY src ./src

# World to enter. Override to point at your own deployment.
ENV AGENT_HOST=https://miduo100.com

# stdio MCP server: keep stdout clean, logs go to stderr.
CMD ["node", "src/index.js"]
