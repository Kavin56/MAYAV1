# RunPod: Run MAYA-V1 with ngrok

Use this on a **new RunPod** (SSH or Jupyter terminal). Your app will be reachable at your ngrok URL (e.g. `https://unameliorative-regretably-kimberly.ngrok-free.dev`).

## 1. System packages

```bash
apt-get update -qq && apt-get install -y curl wget git unzip
```

## 2. Node.js 20

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
```

## 3. OpenCode (optional, if you use it)

```bash
curl -fsSL https://opencode.ai/install | sh
source ~/.bashrc
```

## 4. Install ngrok

```bash
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list
apt-get update && apt-get install -y ngrok
```

Or one-line (standalone):

```bash
curl -sSL https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz | tar xz -C /usr/local/bin
```

## 5. Clone MAYA-V1

```bash
git clone https://github.com/Kavin56/MAYAV1.git /workspace/MAYAV1
cd /workspace/MAYAV1
git checkout dev
```

## 6. Create `.env` with your ngrok credentials

**Do not commit `.env`.** On the RunPod machine only:

```bash
cat > .env << 'ENVEOF'
# Ngrok – use your own token and domain
NGROK_AUTHTOKEN=paste_your_ngrok_authtoken_here
NGROK_DOMAIN=unameliorative-regretably-kimberly.ngrok-free.dev

# Optional: RunPod API (for RunPod integration in the app)
# RUNPOD_API_KEY=your_runpod_api_key
# RUNPOD_ENDPOINT_ID=your_runpod_endpoint_id
ENVEOF
```

Then edit and paste your real token:

```bash
nano .env
# Replace paste_your_ngrok_authtoken_here with your actual ngrok authtoken
```

- **NGROK_AUTHTOKEN**: from [ngrok Dashboard → Your Authtoken](https://dashboard.ngrok.com/get-started/your-authtoken) (e.g. `3AsGlODWFrruTjeoUYbH3N0uVgN_...`).
- **NGROK_DOMAIN**: subdomain only, no `https://` — e.g. `unameliorative-regretably-kimberly.ngrok-free.dev`.

## 7. Run the startup script

```bash
chmod +x runpod-start.sh
./runpod-start.sh
```

This will:

- Load `.env` (so `NGROK_AUTHTOKEN` and `NGROK_DOMAIN` are set).
- Start **ngrok** pointing at the MAYA server port (3000 or 8000).
- Start the **MAYA** server (Python).

Your MAYA API will be available at:

- **Public URL:** `https://unameliorative-regretably-kimberly.ngrok-free.dev`
- **On Pod:** `http://localhost:3000` (or `http://localhost:8000` if using FastAPI)

## 8. Quick health check

From your laptop:

```bash
curl https://unameliorative-regretably-kimberly.ngrok-free.dev/health
```

You may need to pass the ngrok browser header (free tier):

```bash
curl -H "ngrok-skip-browser-warning: true" https://unameliorative-regretably-kimberly.ngrok-free.dev/health
```

---

## One-time setup (RunPod Template or startup script)

If you use a **RunPod Template** or a single startup script, paste the following and **replace the placeholder token** with your real ngrok authtoken:

```bash
apt-get update -qq && apt-get install -y curl wget git unzip
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
curl -sSL https://ngrok-agent.s3.amazonaws.com/ngrok.asc | tee /etc/apt/trusted.gpg.d/ngrok.asc >/dev/null
echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | tee /etc/apt/sources.list.d/ngrok.list
apt-get update && apt-get install -y ngrok

git clone https://github.com/Kavin56/MAYAV1.git /workspace/MAYAV1
cd /workspace/MAYAV1
git checkout dev

# Create .env (replace YOUR_NGROK_TOKEN with your real token)
echo "NGROK_AUTHTOKEN=YOUR_NGROK_TOKEN" > .env
echo "NGROK_DOMAIN=unameliorative-regretably-kimberly.ngrok-free.dev" >> .env

chmod +x runpod-start.sh
./runpod-start.sh
```

Security: store your token in RunPod’s **Environment Variables** (e.g. `NGROK_AUTHTOKEN`) and use `echo "NGROK_AUTHTOKEN=$NGROK_AUTHTOKEN" >> .env` instead of hardcoding.
