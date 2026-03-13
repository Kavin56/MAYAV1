:#!/bin/bash
set -e

echo "🚀 MAYA Local Deployment Script"
echo "================================"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

log "Starting MAYA local deployment..."

# Create necessary directories
mkdir -p {logs,config,data,skills,temp}

# Set permissions
chmod +x entrypoint.sh 2>/dev/null || true

# Generate environment file if not exists
if [ ! -f .env ]; then
    log "Generating environment configuration..."
    cat > .env << EOF
NODE_ENV=production
MAYA_VERSION=1.0.0
MAYA_SOUL_PATH=/opt/maya/soul
MAYA_CONFIG_PATH=/opt/maya/config
MAYA_LOG_LEVEL=info
MAYA_HEARTBEAT_INTERVAL=21600
MAYA_SELF_EVOLUTION=true
MAYA_SOCIAL_MEDIA_BRIDGE=true
GMAIL_USER=surya.girishad@gmail.com
GMAIL_PASS=Surya@2003
RUNPOD_API_KEY=demo_key
RUNPOD_ENDPOINT_ID=demo_endpoint
CHROME_TOKEN=maya_chrome_secret_token
REDIS_HOST=localhost
REDIS_PORT=6379
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRES_IN=7d
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
EOF
fi

# Create social media config if not exists
if [ ! -f config/social-media.json ]; then
    log "Creating social media configuration..."
    mkdir -p config
    cat > config/social-media.json << EOF
{
  "platforms": {
    "instagram": {
      "enabled": true,
      "credentials": {
        "email": "surya.girishad@gmail.com"
      },
      "settings": {
        "browser_endpoint": "http://chrome-headless:9222",
        "session_persistence": true,
        "human_behavior_simulation": true,
        "rate_limiting": true,
        "max_actions_per_hour": 60
      },
      "automation": {
        "posting": true,
        "story_upload": true,
        "engagement": true,
        "analytics": true
      }
    },
    "facebook": {
      "enabled": true,
      "credentials": {
        "email": "surya.girishad@gmail.com"
      },
      "settings": {
        "browser_endpoint": "http://chrome-headless:9222",
        "session_persistence": true,
        "human_behavior_simulation": true,
        "rate_limiting": true,
        "max_actions_per_hour": 60
      },
      "automation": {
        "page_management": true,
        "group_engagement": true,
        "posting": true,
        "analytics": true
      }
    }
  }
}
EOF
fi