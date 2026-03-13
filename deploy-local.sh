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

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    error "Docker is not installed. Please install Docker first."
fi

if ! command -v docker-compose &> /dev/null; then
    error "Docker Compose is not installed. Please install Docker Compose first."
fi

log "Starting MAYA local deployment..."

# Create necessary directories
mkdir -p {logs,config,data,skills,temp}

# Set permissions
chmod +x entrypoint.sh

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
REDIS_HOST=redis
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

# Pull Docker images
log "Pulling Docker images..."
docker-compose pull

# Start services
log "Starting MAYA services..."
docker-compose up -d

# Wait for services to start
log "Waiting for services to start..."
sleep 30

# Check service status
log "Checking service status..."
docker-compose ps

# Show initial logs
log "Showing initial service logs..."
docker-compose logs --tail=50

# Test health endpoint
log "Testing health endpoint..."
sleep 10
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    log "✅ MAYA is healthy and running!"
else
    warning "⚠️  Health check failed, checking logs..."
    docker-compose logs maya-orchestrator | tail -20
fi

log "🎉 MAYA deployment completed successfully!"
echo ""
echo "Access points:"
echo "- Main Application: http://localhost:3000"
echo "- Grafana Dashboard: http://localhost:3001"
echo "- Prometheus Metrics: http://localhost:9090"
echo ""
echo "Commands:"
echo "- View logs: docker-compose logs -f"
echo "- Stop services: docker-compose down"
echo "- Restart: docker-compose restart"
echo "- Check status: docker-compose ps"
echo ""
echo "🚀 Your self-evolving digital marketing agent is ready!"