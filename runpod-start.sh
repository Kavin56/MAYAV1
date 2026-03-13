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

# Determine which server we'll run (for ngrok port)
USE_FASTAPI=
if [ -f src/main.py ]; then
  first_line=$(head -1 src/main.py)
  if echo "$first_line" | grep -qE '^#!.*python|^#!/usr/bin/env python|^"""|^import |^from '; then
    [ -f requirements.txt ] && USE_FASTAPI=1
  fi
fi
MAYA_PORT=$([ -n "$USE_FASTAPI" ] && echo 8000 || echo 3000)

# Optional: start ngrok to expose the server (use new token/URL if you hit limits)
if [ -n "$NGROK_AUTHTOKEN" ]; then
  if command -v ngrok >/dev/null 2>&1; then
    PORT=${MAYA_PORT}
    echo "🔗 Starting ngrok for port $PORT..."
    # Use --url (not deprecated --domain); --pooling-enabled when using same URL on multiple Pods
    if [ -n "$NGROK_DOMAIN" ]; then
      NGROK_URL="https://${NGROK_DOMAIN#https://}"
      ngrok http "$PORT" --authtoken "$NGROK_AUTHTOKEN" --url "$NGROK_URL" --pooling-enabled &
    else
      ngrok http "$PORT" --authtoken "$NGROK_AUTHTOKEN" &
    fi
    NGROK_PID=$!
  else
    echo "⚠️ NGROK_AUTHTOKEN set but ngrok not installed; install from https://ngrok.com/download"
  fi
fi

if [ -n "$USE_FASTAPI" ]; then
  if [ ! -d venv ]; then
    echo "📦 Creating venv..."
    python3 -m venv venv
  fi
  source venv/bin/activate
  pip install -q -r requirements.txt
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
