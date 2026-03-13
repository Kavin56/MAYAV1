#!/usr/bin/env bash
# MAYA-V1 RunPod startup — no source build. Uses global openwork-orchestrator + FastAPI + Caddy + ngrok.
# Pull from git and run: bash runpod-start.sh (requires .env with NGROK_AUTHTOKEN)
echo "[MAYA] runpod-start.sh starting..."
set -e

echo "[MAYA] Loading .env..."
if [ -f .env ]; then
  set -a
  source .env 2>/dev/null || true
  set +a
  echo "[MAYA] .env loaded."
else
  echo "[MAYA] No .env file in $(pwd). Create it with NGROK_AUTHTOKEN=your_token"
fi
mkdir -p logs tmp

OPENWORK_WORKSPACE="${OPENWORK_WORKSPACE:-$(pwd)}"
OPENWORK_PORT="${OPENWORK_PORT:-8787}"
MAYA_PYTHON_PORT="${MAYA_PYTHON_PORT:-8000}"
PUBLIC_PORT="${PUBLIC_PORT:-8080}"
MAYA_PYTHON_APP="${MAYA_PYTHON_APP:-src/main.py}"

if [ -z "${NGROK_AUTHTOKEN:-}" ]; then
  echo "[MAYA] ERROR: NGROK_AUTHTOKEN required. Set it in .env or export it, then run again."
  exit 1
fi
echo "[MAYA] NGROK_AUTHTOKEN is set. Proceeding..."

ensure_ngrok() {
  command -v ngrok >/dev/null 2>&1 && return 0
  echo "📦 Installing ngrok..."
  apt-get update -qq && apt-get install -y curl unzip
  arch=$(uname -m); [ "$arch" = "x86_64" ] || [ "$arch" = "amd64" ] && arch="amd64" || arch="arm64"
  curl -fsSL "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-${arch}.zip" -o /tmp/ngrok.zip
  unzip -o /tmp/ngrok.zip -d /usr/local/bin && chmod +x /usr/local/bin/ngrok
}

ensure_caddy() {
  command -v caddy >/dev/null 2>&1 && return 0
  echo "📦 Installing caddy..."
  apt-get update -qq && apt-get install -y caddy 2>/dev/null || true
  if ! command -v caddy >/dev/null 2>&1; then
    curl -fsSL "https://caddyserver.com/api/download?os=linux&arch=amd64" -o /usr/local/bin/caddy
    chmod +x /usr/local/bin/caddy
  fi
}

start_openwork() {
  echo "🧠 Starting OpenWork (port ${OPENWORK_PORT})..."
  if ! command -v openwork >/dev/null 2>&1; then
    echo "📦 Installing openwork-orchestrator (global)..."
    npm i -g openwork-orchestrator
  fi
  export OPENWORK_HOST="${OPENWORK_HOST:-127.0.0.1}" OPENWORK_PORT="${OPENWORK_PORT}"
  export OPENWORK_APPROVAL_MODE="${OPENWORK_APPROVAL_MODE:-auto}" OPENWORK_CORS_ORIGINS="${OPENWORK_CORS_ORIGINS:-*}"
  openwork serve --workspace "${OPENWORK_WORKSPACE}" --no-tui >/tmp/openwork.log 2>&1 &
  OPENWORK_PID=$!
}

start_python() {
  echo "🐍 Starting FastAPI (port ${MAYA_PYTHON_PORT})..."
  [ ! -d venv ] && python3 -m venv venv
  source venv/bin/activate
  [ -f requirements.txt ] && pip install -q -r requirements.txt || pip install -q fastapi uvicorn pydantic python-dotenv
  export PORT="${MAYA_PYTHON_PORT}"
  python3 "${MAYA_PYTHON_APP}" >/tmp/maya-fastapi.log 2>&1 &
  MAYA_PID=$!
}

start_proxy() {
  ensure_caddy
  echo "🌐 Starting proxy on 0.0.0.0:${PUBLIC_PORT}..."
  cat > tmp/Caddyfile <<EOF
:${PUBLIC_PORT} {
  @maya path /maya/*
  handle @maya { uri strip_prefix /maya; reverse_proxy 127.0.0.1:${MAYA_PYTHON_PORT} }
  handle { reverse_proxy 127.0.0.1:${OPENWORK_PORT} }
}
EOF
  caddy run --config tmp/Caddyfile --adapter caddyfile >/tmp/caddy.log 2>&1 &
  CADDY_PID=$!
}

start_ngrok() {
  ensure_ngrok
  echo "🔗 Starting ngrok -> localhost:${PUBLIC_PORT}"
  ngrok http "${PUBLIC_PORT}" --authtoken "${NGROK_AUTHTOKEN}" ${NGROK_DOMAIN:+--domain="${NGROK_DOMAIN}"} >/tmp/ngrok.log 2>&1 &
  NGROK_PID=$!
  [ -n "${NGROK_DOMAIN:-}" ] && echo "https://${NGROK_DOMAIN}" > tmp/public-url.txt || echo "(see /tmp/ngrok.log)" > tmp/public-url.txt
}

trap 'kill ${NGROK_PID:-} ${CADDY_PID:-} ${OPENWORK_PID:-} ${MAYA_PID:-} 2>/dev/null || true' EXIT
start_openwork; start_python; start_proxy; start_ngrok
echo "✅ Started. OpenWork: 127.0.0.1:${OPENWORK_PORT} | FastAPI: 127.0.0.1:${MAYA_PYTHON_PORT} | Public: $(cat tmp/public-url.txt)"
echo "Logs: /tmp/openwork.log /tmp/maya-fastapi.log /tmp/caddy.log /tmp/ngrok.log"
wait
