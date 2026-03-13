#!/usr/bin/env bash
# MAYA-V1 RunPod: run MAYA server (Node) + ngrok so frontend can connect.
# Frontend uses: MAYA server URL = ngrok URL, token = MAYA_TOKEN (or printed).
# OpenCode + MAYA status in the app both work when you connect to this ngrok URL.

set -e

MAYA_PORT=8787
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "🚀 MAYA-V1 RunPod startup (frontend + ngrok)"

# Default ngrok URL (hardcoded)
DEFAULT_NGROK_DOMAIN="unameliorative-regretably-kimberly.ngrok-free.dev"

# Load .env
if [ -f .env ]; then
  echo "📁 Loading .env..."
  set -a
  # shellcheck disable=SC1090
  source .env
  set +a
fi
NGROK_DOMAIN="${NGROK_DOMAIN:-$DEFAULT_NGROK_DOMAIN}"

# Token for frontend (set in .env or we generate and print)
MAYA_TOKEN="${MAYA_TOKEN:-}"
if [ -z "$MAYA_TOKEN" ]; then
  MAYA_TOKEN=$(openssl rand -hex 24 2>/dev/null || echo "runpod-$(date +%s)")
  echo "📌 Generated MAYA_TOKEN (save for frontend): $MAYA_TOKEN"
fi

mkdir -p logs

# ─── ngrok (expose MAYA server for frontend) ───
# Use --pooling-enabled so the same URL can run on multiple Pods (ERR_NGROK_334 fix).
if [ -n "$NGROK_AUTHTOKEN" ]; then
  if command -v ngrok >/dev/null 2>&1; then
    echo "🔗 Starting ngrok for port $MAYA_PORT..."
    if [ -n "$NGROK_DOMAIN" ]; then
      NGROK_URL="https://${NGROK_DOMAIN#https://}"
      ngrok http "$MAYA_PORT" --url "$NGROK_URL" --pooling-enabled --authtoken "$NGROK_AUTHTOKEN" &
    else
      ngrok http "$MAYA_PORT" --authtoken "$NGROK_AUTHTOKEN" &
    fi
    sleep 2
  else
    echo "⚠️ ngrok not installed; install from https://ngrok.com/download"
  fi
fi

# ─── MAYA server (Node) – frontend talks to this via ngrok ───
echo "📦 Building MAYA server..."
if ! command -v pnpm >/dev/null 2>&1; then
  npm install -g pnpm
fi
pnpm install
pnpm --filter maya-server build

# Workspace: current dir on RunPod
WORKSPACE_DIR="${MAYA_WORKSPACE:-$ROOT_DIR}"
# Optional: start OpenCode so "OpenCode" shows connected in the app
OPENCODE_URL=""
if command -v opencode >/dev/null 2>&1; then
  echo "🔧 Starting OpenCode on 4096..."
  opencode serve --host 127.0.0.1 --port 4096 &
  sleep 2
  OPENCODE_URL="http://127.0.0.1:4096"
fi

echo "🌐 Starting MAYA server on port $MAYA_PORT..."
SERVER_ARGS=(
  --host 0.0.0.0
  --port "$MAYA_PORT"
  --workspace "$WORKSPACE_DIR"
  --token "$MAYA_TOKEN"
  --cors "*"
)
[ -n "$OPENCODE_URL" ] && SERVER_ARGS+=(--opencode-base-url "$OPENCODE_URL" --opencode-directory "$WORKSPACE_DIR")

(cd packages/server && node dist/cli.js "${SERVER_ARGS[@]}") &
APP_PID=$!

echo ""
echo "✅ MAYA server: http://0.0.0.0:$MAYA_PORT"
echo "   Health: http://localhost:$MAYA_PORT/health"
echo "   Status: http://localhost:$MAYA_PORT/status"
if [ -n "$NGROK_DOMAIN" ]; then
  PUBLIC_URL="https://${NGROK_DOMAIN#https://}"
  echo ""
  echo "━━━ Connect your frontend ━━━"
  echo "   MAYA server URL: $PUBLIC_URL"
  echo "   Token: $MAYA_TOKEN"
  echo "   In the app: Settings → Remote / Advanced → set URL to $PUBLIC_URL and token above."
  echo "   Then OpenCode and MAYA will show connected."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

wait $APP_PID
