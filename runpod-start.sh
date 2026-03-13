#!/usr/bin/env bash
# One-terminal start: MAYA server in background, then ngrok. Run from repo root (e.g. /workspace/MAYAV1).

set -e
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

MAYA_PORT="${MAYA_PORT:-8787}"
HEALTH_URL="http://127.0.0.1:${MAYA_PORT}/health"
MAX_WAIT=90

check_health() {
  if command -v curl >/dev/null 2>&1; then
    curl -sf "$HEALTH_URL" >/dev/null 2>&1
  else
    (command -v wget >/dev/null 2>&1 && wget -q -O- "$HEALTH_URL" >/dev/null 2>&1) || false
  fi
}

# Free port so the new server can bind (avoid EADDRINUSE from a previous run)
if command -v fuser >/dev/null 2>&1; then
  fuser -k "${MAYA_PORT}/tcp" 2>/dev/null || true
  sleep 1
elif command -v lsof >/dev/null 2>&1; then
  PIDS=$(lsof -ti ":${MAYA_PORT}" 2>/dev/null) || true
  if [ -n "$PIDS" ]; then
    echo "$PIDS" | xargs -r kill 2>/dev/null || true
    sleep 1
  fi
fi

echo "[runpod-start] Building MAYA server (so CORS and latest code are used)..."
pnpm --filter maya-server build

echo "[runpod-start] Starting MAYA server in background..."
pnpm --filter maya-server start &
SERVER_PID=$!

echo "[runpod-start] Waiting for server at $HEALTH_URL (max ${MAX_WAIT}s)..."
READY=
for i in $(seq 1 "$MAX_WAIT"); do
  if check_health; then
    printf "\n"
    echo "[runpod-start] Server responded, verifying again..."
    sleep 2
    if check_health; then
      READY=1
      echo "[runpod-start] Server is up."
      break
    fi
  fi
  printf "."
  if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    printf "\n"
    echo "[runpod-start] Server process exited. Aborting."
    exit 1
  fi
  sleep 1
done

if [ -z "$READY" ]; then
  printf "\n"
  echo "[runpod-start] Server did not become ready in time. Stopping."
  kill "$SERVER_PID" 2>/dev/null || true
  exit 1
fi

if [ -n "$NGROK_AUTHTOKEN" ]; then
  export NGROK_AUTHTOKEN
fi

echo "[runpod-start] Starting ngrok..."
if [ -n "$NGROK_DOMAIN" ]; then
  exec ngrok http "$MAYA_PORT" --url="https://${NGROK_DOMAIN}"
else
  exec ngrok http "$MAYA_PORT"
fi
