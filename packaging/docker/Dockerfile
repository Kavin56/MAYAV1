# Production Dockerfile for MAYA Server
# 
# This builds the MAYA orchestrator from local source
# For production, you would publish packages to npm first

FROM node:22-bookworm-slim

# Install system dependencies
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    tar \
    unzip \
  && rm -rf /var/lib/apt/lists/*

# Install bun
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy package files
COPY packages/server/package.json packages/server/package.json
COPY packages/orchestrator/package.json packages/orchestrator/package.json

# Install dependencies
RUN npm install -g typescript

# Copy source
COPY packages/server packages/server
COPY packages/orchestrator packages/orchestrator
COPY packages/opencode-router packages/opencode-router

# Build the server
WORKDIR /app/packages/server
RUN bun build --compile src/cli.ts --outfile /usr/local/bin/maya-server

# Build the orchestrator
WORKDIR /app/packages/orchestrator
RUN bun build --compile src/cli.ts --outfile /usr/local/bin/maya

# Go back to app dir
WORKDIR /app

# Persistent directories
ENV MAYA_DATA_DIR=/data/maya-orchestrator
ENV MAYA_SIDECAR_DIR=/data/sidecars
ENV MAYA_WORKSPACE=/workspace

# Expose ports
EXPOSE 8787
EXPOSE 3005

VOLUME ["/workspace", "/data"]

# Default command - uses environment variables
CMD ["maya", "serve"]
