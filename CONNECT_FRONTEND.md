# Connect the MAYA app to RunPod via ngrok

After you run `./runpod-start.sh` on RunPod, the script prints something like:

```
━━━ Connect your frontend ━━━
   MAYA server URL: https://unameliorative-regretably-kimberly.ngrok-free.dev
   Token: <your-token>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## In the MAYA app (desktop or web)

1. Open **Settings** (or the screen where you add a remote worker).
2. Find **MAYA server URL** / **Remote base URL** / **Connect remote**.
3. Set:
   - **URL:** `https://unameliorative-regretably-kimberly.ngrok-free.dev` (your ngrok URL, no trailing slash)
   - **Token:** the token printed by `runpod-start.sh` (or the one you set in `.env` as `MAYA_TOKEN`)
4. Save / Connect.

Then:

- **MAYA** in the status bar will show **Ready** (the app hits `ngrokurl/health`, `ngrokurl/status`).
- **OpenCode** will show **Connected** if OpenCode is running on RunPod and the server is started with `--opencode-base-url` (the script does this when `opencode` is installed).

## Check from a browser

- **Root:** `https://your-ngrok-url.ngrok-free.dev/` → JSON with service info (no token needed).
- **Health:** `https://your-ngrok-url.ngrok-free.dev/health` → `{"ok":true,...}` (no token needed).
- **Status:** `https://your-ngrok-url.ngrok-free.dev/status` → requires **Authorization: Bearer &lt;token&gt;** (the one printed as "Token:" by the script). Without the token you get `401 Unauthorized` — that means the server is up and auth is working.
- There is no `/token` URL — you **use** the token in the app’s Settings (MAYA server URL + Token). The app sends it in the header when calling `/status`, `/health`, etc.

No RunPod API or extra services are required—only the MAYA server behind ngrok and the token in the app.

## If `git pull` fails on RunPod (local changes)

```bash
git stash
git pull origin dev
git stash pop
# or discard local runpod-start.sh:  git checkout -- runpod-start.sh && git pull origin dev
```
