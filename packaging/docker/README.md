# MAYA Host (Docker)

## Quick Start

### Option 1: Local Development

```bash
cd packaging/docker
docker compose up --build
```

Then open:
- `http://127.0.0.1:8787/ui` - MAYA Web UI
- `http://127.0.0.1:8787/health` - Health check

### Option 2: Production Cloud Deployment

```bash
# Build and run
docker compose up -d --build

# Check logs
docker compose logs -f

# Stop
docker compose down
```

---

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `MAYA_TOKEN` | No | Auto-generated | Client authentication token |
| `MAYA_HOST_TOKEN` | No | Auto-generated | Host/admin authentication token |
| `MAYA_APPROVAL_MODE` | No | `manual` | `auto` or `manual` for approvals |
| `MAYA_APPROVAL_TIMEOUT_MS` | No | `30000` | Approval timeout in milliseconds |
| `MAYA_WORKSPACES` | No | - | JSON array of workspace paths |
| `MAYA_CORS_ORIGINS` | No | `*` | Allowed CORS origins |
| `MAYA_READONLY` | No | `false` | Enable read-only mode |
| `MAYA_LOG_FORMAT` | No | `pretty` | `pretty` or `json` |

---

## Volume Mounts

| Path | Description |
|------|-------------|
| `/workspace` | Your project files (REQUIRED) |
| `/data` | Persistent data (caches, tokens, config) |

---

## Cloud Deployment Guide

### Recommended: DigitalOcean Droplet

1. **Create a Droplet** ($12/mo minimum)
   - Ubuntu 22.04 LTS
   - 2GB RAM, 1 vCPU, 50GB SSD

2. **Install Docker**
   ```bash
   curl -fsSL get.docker.com | sh
   sudo usermod -aG docker $USER
   ```

3. **Deploy MAYA**
   ```bash
   # Clone your MAYA repo or copy files
   cd packaging/docker
   
   # Create workspace directory
   mkdir -p ~/workspace
   
   # Set tokens
   export MAYA_TOKEN="your-secure-token"
   export MAYA_HOST_TOKEN="your-host-token"
   
   # Run
   docker compose up -d
   ```

4. **Enable Firewall**
   ```bash
   sudo ufw allow 8787/tcp
   sudo ufw enable
   ```

### Alternative: Railway

1. Connect GitHub repo to Railway
2. Set environment variables in Railway dashboard
3. Deploy automatically

### Alternative: Hetzner (EU)

1. Create Hetzner Cloud project
2. Install Docker: `curl -fsSL get.docker.com | sh`
3. Deploy using docker-compose

---

## Hybrid Cloud Model (Access Local Files from Cloud)

### Option A: Tailscale VPN

1. **On your home PC (always on)**:
   ```bash
   # Install Tailscale
   curl -fsSL https://tailscale.com/install.sh | sh
   
   # Authenticate
   tailscale up
   
   # Note your Tailscale IP (e.g., 100.x.x.x)
   tailscale ip -4
   ```

2. **On Cloud Server**:
   ```bash
   # Install Tailscale
   curl -fsSL https://tailscale.com/install.sh | sh
   
   # Authenticate (use same account)
   tailscale up
   
   # Mount home files via Tailscale
   tailscale mount /home/user/workspace ~/cloud-workspace
   ```

3. **Update docker-compose.yml** to mount `~/cloud-workspace:/workspace`

### Option B: Git Sync

1. Push workspace to GitHub
2. On cloud server: `git clone` on startup
3. Use GitHub Actions or cron for periodic sync

---

## Health Checks

```bash
# Check container health
docker inspect maya-server --format='{{.State.Health.Status}}'

# Manual health check
curl http://localhost:8787/health
```

---

## Troubleshooting

### Container won't start
```bash
# Check logs
docker compose logs maya

# Verify ports aren't in use
sudo lsof -i :8787
```

### Can't connect from remote
```bash
# Check firewall
sudo ufw status

# Allow port
sudo ufw allow 8787/tcp
```

### Workspace files not accessible
```bash
# Verify volume mount
docker inspect maya-server --format='{{range .Mounts}}{{.Source}} -> {{.Destination}}{{println}}{{end}}'
```

---

## Ports Reference

| Port | Service |
|------|---------|
| 8787 | MAYA Server API |
| 3005 | OpenCode Router (if enabled) |
