# RunPod: pull and start (copy-paste each time)

Run this block on your RunPod (SSH or Jupyter terminal) after any update:

```bash
cd /workspace/MAYAV1
git stash
git pull origin dev
chmod +x runpod-start.sh
./runpod-start.sh
```

**First time only** (or if you don’t have `.env` yet), create `.env` with your ngrok token:

```bash
cd /workspace/MAYAV1
cat > .env << 'EOF'
NGROK_AUTHTOKEN=paste_your_ngrok_authtoken_here
MAYA_TOKEN=your_secret_token_for_app
EOF
# Then: nano .env  (paste real NGROK_AUTHTOKEN and MAYA_TOKEN)
```

Default ngrok URL is hardcoded (`unameliorative-regretably-kimberly.ngrok-free.dev`); no need to set `NGROK_DOMAIN` unless you change it.

---

**One-liner (pull + start, no stash):**

```bash
cd /workspace/MAYAV1 && git fetch origin dev && git reset --hard origin/dev && chmod +x runpod-start.sh && ./runpod-start.sh
```

*(Use this only if you’re okay discarding any local changes on the Pod.)*

---

## Ngrok setup (ERR_NGROK_334: “endpoint already online”)

That error means the same ngrok URL is already in use (e.g. another RunPod or your laptop). Two options:

1. **Use pooling (recommended)**  
   The script now starts ngrok with `--pooling-enabled` so the **same URL** can serve multiple endpoints (e.g. several RunPods). **Pull the latest code** and run again:
   ```bash
   cd /workspace/MAYAV1 && git fetch origin dev && git reset --hard origin/dev && ./runpod-start.sh
   ```

2. **Use only one endpoint**  
   Stop ngrok everywhere else that uses `unameliorative-regretably-kimberly.ngrok-free.dev` (other RunPod sessions, local terminal), then start again on this Pod.

**Get your ngrok token:** [dashboard.ngrok.com → Your Authtoken](https://dashboard.ngrok.com/get-started/your-authtoken). Put it in `.env` as `NGROK_AUTHTOKEN=your_token`.

**If ngrok keeps failing:** the script still starts the MAYA server. Use **RunPod’s HTTP proxy** for port **8787** (in the RunPod dashboard, open the proxy URL for 8787) and use that URL + token in the app instead of the ngrok URL.
