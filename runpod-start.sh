#!/usr/bin/env bash
# MAYA-V1 RunPod startup script
# Run this after: clone repo, then chmod +x runpod-start.sh && ./runpod-start.sh
# Optional env: RUNPOD_API_KEY, RUNPOD_ENDPOINT_ID, NGROK_AUTHTOKEN, NGROK_DOMAIN

set -e

echo "🚀 MAYA-V1 RunPod startup"

# Load .env if present (do not commit .env with secrets)
if [ -f .env ]; then
  echo "📁 Loading .env..."
  set -a
  # shellcheck disable=SC1090
  source .env
  set +a
fi

# Create logs dir for maya_server.py
mkdir -p logs

# Optional: start ngrok to expose the server (use new token/URL if you hit limits)
if [ -n "$NGROK_AUTHTOKEN" ]; then
  if command -v ngrok >/dev/null 2>&1; then
    PORT=${MAYA_PORT:-3000}
    [ -f src/main.py ] && PORT=8000
    echo "🔗 Starting ngrok for port $PORT (set NGROK_AUTHTOKEN in .env to use a new account)..."
    ngrok http "$PORT" --authtoken "$NGROK_AUTHTOKEN" ${NGROK_DOMAIN:+--domain="$NGROK_DOMAIN"} &
    NGROK_PID=$!
  else
    echo "⚠️ NGROK_AUTHTOKEN set but ngrok not installed; install from https://ngrok.com/download"
  fi
fi

# Prefer FastAPI app if present and dependencies exist
if [ -f src/main.py ]; then
  if [ ! -d venv ]; then
    echo "📦 Creating venv..."
    python3 -m venv venv
  fi
  source venv/bin/activate
  if [ -f requirements.txt ]; then
    pip install -q -r requirements.txt
  else
    echo "⚠️ No requirements.txt; installing minimal deps for src/main.py..."
    pip install -q fastapi uvicorn pydantic 2>/dev/null || true
  fi
  echo "🌐 Starting FastAPI (port 8000)..."
  python3 src/main.py &
  APP_PID=$!
  echo "✅ MAYA FastAPI: http://localhost:8000"
  echo "   Health: http://localhost:8000/health"
  echo "   RunPod status: http://localhost:8000/api/runpod/status"
  wait $APP_PID
else
  echo "🌐 Starting MAYA HTTP server (port 3000)..."
  python3 maya_server.py &
  APP_PID=$!
  echo "✅ MAYA server: http://localhost:3000"
  echo "   Health: http://localhost:3000/health"
  echo "   RunPod status: http://localhost:3000/api/runpod/status"
  wait $APP_PID
fi
