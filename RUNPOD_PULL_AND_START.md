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
