# MAYA-V1: Codebase Summary, Ngrok, Git & RunPod

## 1. Codebase context (folder & docs)

**Target repo:** `d:\MAYA-V1` (this repo)  
**Out of scope:** OpenCode upstream, other forks.

### What this repo is

- **OpenWork/MAYA fork**: OpenWork is an open-source “Claude Cowork–style” desktop app that runs agents, skills, and MCP on top of **OpenCode**. This fork is branded **MAYA** (Self-Evolving Digital Marketing Agent).
- **Key docs**: `AGENTS.md`, `VISION.md`, `PRINCIPLES.md`, `PRODUCT.md`, `ARCHITECTURE.md`, `INFRASTRUCTURE.md`, `README.md`.
- **Structure**:
  - **Desktop/app**: `packages/app` (SolidJS UI), `packages/desktop` (Tauri 2 shell).
  - **Backend/orchestration**: `packages/server`, `packages/orchestrator` (maya/orchestrator), OpenCode integration.
  - **MAYA-specific**: `maya_server.py` (simple HTTP server on port 3000), `src/main.py` (FastAPI on 8000), RunPod integration in both.
  - **Deployment**: `RUNPOD_DEPLOYMENT.md`, `deploy-runpod-final.sh`, `Dockerfile.runpod`, `entrypoint.sh`, `docker-compose.yml`, various `deploy*.sh`.
- **RunPod**: Config and API keys are via `RUNPOD_API_KEY`, `RUNPOD_ENDPOINT_ID`; docs mention exposing port 8000 for the API. No **ngrok** reference exists in this repo; ngrok is likely used in your other repo (e.g. Kavin56/MAYA) or in your own RunPod/startup scripts to expose the server.

---

## 2. Replacing ngrok (new account, token, URL)

Because ngrok isn’t in this repo, the steps below are generic. Use them wherever you currently run ngrok (e.g. in `runpod-start.sh` or in the repo you clone on RunPod).

### Step 1: New ngrok account & token

1. Sign up at [ngrok](https://ngrok.com) (or use a second account).
2. In Dashboard: **Your Authtoken** → copy the token.
3. (Optional) Reserve a domain or use a new region to get a new URL and avoid the same limits.

### Step 2: Where to set the new token and URL

- **Environment variables** (recommended):  
  Set on the machine/Pod where ngrok runs (e.g. in RunPod template or in your startup script):
  ```bash
  export NGROK_AUTHTOKEN="your_new_ngrok_authtoken"
  # If you use a reserved domain:
  export NGROK_DOMAIN="your-subdomain.ngrok-free.app"
  ```
- **Config file**:  
  If you use `ngrok config edit`, replace the old `authtoken` (and `domain` if used) with the new values.
- **In this repo**:  
  You can keep ngrok out of git by using a local `.env` (see root `.env.example`). Add there:
  ```env
  # Ngrok (optional – for exposing local/Pod server)
  NGROK_AUTHTOKEN=your_ngrok_authtoken
  # NGROK_DOMAIN=your-subdomain.ngrok-free.app
  ```
  Then in your RunPod startup script, before starting ngrok:
  ```bash
  [ -f .env ] && export $(grep -v '^#' .env | xargs)
  ngrok http 3000 --authtoken "$NGROK_AUTHTOKEN" ${NGROK_DOMAIN:+--domain="$NGROK_DOMAIN"}
  ```

### Step 3: Use the new URL

- After starting ngrok, the **public URL** is shown in the ngrok terminal or at [Dashboard → Tunnels](https://dashboard.ngrok.com/tunnels).
- Replace any old ngrok URL in:
  - RunPod env vars or config that point clients to your server.
  - Scripts or docs that reference the previous ngrok URL.

### Step 4: If you hit limits again

- Use a **paid ngrok plan** for more tunnels/connections, or
- Switch to another tunnel (e.g. **Cloudflare Tunnel**, **Tailscale Funnel**, or RunPod’s **TCP/HTTP proxy** for the Pod) and update the same env/config to the new URL and token.

---

## 3. Git: commit, push, and repo

- **You should create the new repo yourself** (on GitHub/GitLab/etc.). The assistant cannot create a repo on your account (no auth).
- After the repo exists:

```bash
cd d:\MAYA-V1

# If this folder isn’t a git repo yet
git init

# Add your remote (replace with your real repo URL)
git remote add origin https://github.com/YOUR_USERNAME/MAYA-V1.git

# Stage and commit
git add .
git commit -m "MAYA-V1: RunPod setup, docs, ngrok guide"

# Push (first time)
git push -u origin main
# Or if your default branch is dev:
# git push -u origin dev
```

- If **MAYA-V1** is already a clone of another repo, just add your new remote and push:

```bash
git remote add myfork https://github.com/YOUR_USERNAME/MAYA-V1.git
git push myfork main
```

- **Do not commit** `.env` or any file containing `NGROK_AUTHTOKEN` or other secrets. Keep them in `.env` and add `.env` to `.gitignore` if it isn’t already.

---

## 4. How to run on RunPod (with your usual flow)

You usually run something like:

```bash
# System
apt-get update -qq && apt-get install -y curl wget git unzip

# Node 20
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# OpenCode
curl -fsSL https://opencode.ai/install | sh
source ~/.bashrc

# Clone repo
git clone https://github.com/Kavin56/MAYA.git /workspace/MAYA
cd /workspace/MAYA

# Start
chmod +x runpod-start.sh
./runpod-start.sh
```

To run **MAYA-V1** on RunPod in a similar way:

### Option A: Use the provided `runpod-start.sh` (this repo)

1. Clone **this** repo (MAYA-V1) on the Pod and run the script (see script for required env vars):

```bash
apt-get update -qq && apt-get install -y curl wget git unzip
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
curl -fsSL https://opencode.ai/install | sh
source ~/.bashrc

# Clone MAYA-V1 (replace with your repo URL once pushed)
git clone https://github.com/YOUR_USERNAME/MAYA-V1.git /workspace/MAYA-V1
cd /workspace/MAYA-V1

chmod +x runpod-start.sh
./runpod-start.sh
```

2. Set env vars (e.g. in RunPod template or before `./runpod-start.sh`):

- `RUNPOD_API_KEY`, `RUNPOD_ENDPOINT_ID` – for RunPod API.
- `NGROK_AUTHTOKEN` (and optionally `NGROK_DOMAIN`) – only if the script starts ngrok.

### Option B: Same stack, then only Python/MAYA server

If you don’t need the full deploy script and only want Node + OpenCode + MAYA backend:

```bash
apt-get update -qq && apt-get install -y curl wget git unzip python3-pip python3-venv
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
curl -fsSL https://opencode.ai/install | sh
source ~/.bashrc

git clone https://github.com/YOUR_USERNAME/MAYA-V1.git /workspace/MAYA-V1
cd /workspace/MAYA-V1

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt   # if present; else install deps from deploy-runpod-final.sh
python3 maya_server.py             # port 3000
# Or: python3 src/main.py         # port 8000
```

### Exposing the app on RunPod

- Use RunPod’s **HTTP/TCP proxy** for the Pod (e.g. port 3000 or 8000) so you get a stable URL, or
- Run **ngrok** (or another tunnel) inside the Pod with the **new** token/URL as in section 2, and point clients to the new public URL.

---

## Quick reference

| Topic        | Where / What |
|-------------|----------------|
| Codebase    | OpenWork/MAYA fork; `AGENTS.md`, `README.md`, `ARCHITECTURE.md`. |
| Ngrok       | Not in repo; replace token/URL in env or ngrok config where you run ngrok; optional vars in `.env.example`. |
| Git         | You create the repo; then `git remote add origin …`, `git add .`, `git commit`, `git push`. |
| RunPod      | Use `runpod-start.sh` in this repo (Option A) or the manual Python steps (Option B); set RunPod + optional ngrok env vars. |
