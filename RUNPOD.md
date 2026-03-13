# RunPod setup (MAYA / OpenWork)

**Local worker** = you pick a folder on your machine; OpenCode and OpenWork run there.  
**Remote worker** = same idea, but the folder lives on RunPod (or another server); OpenCode runs there and you connect via a public URL (e.g. ngrok).

This repo’s RunPod script starts OpenWork + FastAPI behind one ngrok URL and exposes `/token` for the client.

## Quick run

```bash
cd /workspace/MAYA
git fetch origin && git reset --hard origin/main
# Create .env with: NGROK_AUTHTOKEN=your_ngrok_token
bash runpod-start.sh
```

(Use tmux/screen if you need it to keep running after closing the terminal.)

Then use the ngrok URL in the app: **Settings → Advanced → Connection → Remote connection**.

---

## Fixing ERR_NGROK_8012 (connection refused to localhost:8080)

This means ngrok is running but **nothing is listening on port 8080** on the RunPod machine (the script stopped or the proxy died).

**Do this:**

1. **Stop any old processes** (optional but clean):
   ```bash
   pkill -f "runpod-start.sh" 2>/dev/null || true
   pkill -f "caddy run"       2>/dev/null || true
   pkill -f "ngrok http"      2>/dev/null || true
   ```

2. **Start the stack again:**
   ```bash
   cd /workspace/MAYA
   git fetch origin && git reset --hard origin/main
   bash runpod-start.sh
   ```

3. **Check that 8080 is up** (in another terminal if needed):
   ```bash
   sleep 15
   curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/
   ```
   You should see `200` (or another 2xx). If you see “Connection refused”, check:
   - `tail -50 /tmp/runpod-start.log`
   - `tail -30 /tmp/caddy.log`
   - `tail -30 /tmp/python-proxy.log`

4. **Check ngrok:**
   ```bash
   cat /workspace/MAYA/tmp/public-url.txt
   # or
   grep -o 'https://[^"]*ngrok[^"]*' /tmp/ngrok.log | tail -1
   ```

If the script exits (e.g. you closed the terminal), Caddy and the proxy stop, so 8080 is closed and ngrok returns ERR_NGROK_8012. Use **tmux** or **screen** if you need the stack to keep running after closing the terminal.

---

## Token

- The script writes the OpenWork client token to `tmp/token.json` and serves it at **GET /token**.
- In the app: **Settings → Advanced → Connection → Remote connection** → set your ngrok URL → click **Fetch token from /token**. Then use **Connect remote** / **Add Remote Worker** (path optional, default `/workspace`).
