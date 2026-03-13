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

# Check Python availability
if command -v python3 &> /dev/null; then
    log "✅ Python 3 is available"
    
    # Start the Python server
    log "Starting MAYA Python server..."
    python3 maya_server.py &
    SERVER_PID=$!
    
    # Wait for server to start
    sleep 2
    
    # Test the server
    if curl -f http://localhost:3000/health > /dev/null 2>&1; then
        log "✅ MAYA Python server is running successfully!"
        log "Server PID: $SERVER_PID"
        log "Access: http://localhost:3000"
        
        # Test other endpoints
        log "Testing API endpoints..."
        echo ""
        curl -s http://localhost:3000/api | python3 -m json.tool
        echo ""
        
        # Show server info
        log "🎯 MAYA is ready for social media automation!"
        echo ""
        echo "🌐 Access Points:"
        echo "  • Health Check: http://localhost:3000/health"
        echo "  • API Info: http://localhost:3000/api"
        echo "  • RunPod Status: http://localhost:3000/api/runpod/status"
        echo "  • Analytics: http://localhost:3000/api/analytics/overview"
        echo "  • Evolution Status: http://localhost:3000/api/evolution/status"
        echo ""
        echo "📊 Test Social Media Scheduling:"
        echo "  • POST to http://localhost:3000/api/social-media/schedule"
        echo "  • Example: curl -X POST http://localhost:3000/api/social-media/schedule -H 'Content-Type: application/json' -d '{\"platform\": \"instagram\", \"content\": \"Test post\", \"schedule_time\": \"2024-01-01T12:00:00\"}'"
        echo ""
        echo "🚀 Your self-evolving digital marketing agent is ready!"
        echo "   MAYA will now handle your social media marketing 24/7!"
        echo ""
        echo "💡 To stop MAYA: kill $SERVER_PID"
        
    else
        error "❌ Server failed to start. Check logs above."
    fi
    
else
    error "❌ Python 3 is not available. Please install Python 3 to run MAYA."
fi

log "🎉 MAYA deployment completed successfully!"

# Save PID for management
echo $SERVER_PID > maya.pid
log "Server PID saved to maya.pid"