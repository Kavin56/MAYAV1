:#!/bin/bash
set -e

echo "🚀 MAYA RunPod Startup Script"
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

log "Starting MAYA orchestrator..."

# Setup virtual display for browser automation
log "Setting up virtual display..."
export DISPLAY=:99
Xvfb :99 -screen 0 1920x1080x24 &
sleep 2

# Create necessary directories
mkdir -p {logs,config,data,skills,temp}

# Set permissions
chmod -R 755 /opt/maya

# Create environment configuration
log "Creating environment configuration..."
cat > /opt/maya/.env << EOF
# MAYA Configuration
PYTHONPATH=/opt/maya
NODE_ENV=production
MAYA_VERSION=1.0.0
MAYA_SOUL_PATH=/opt/maya/soul
MAYA_CONFIG_PATH=/opt/maya/config
MAYA_LOG_LEVEL=info
MAYA_HEARTBEAT_INTERVAL=21600
MAYA_SELF_EVOLUTION=true
MAYA_SOCIAL_MEDIA_BRIDGE=true

# Gmail Configuration
GMAIL_USER=surya.girishad@gmail.com
GMAIL_PASS=Surya@2003
GMAIL_SMTP_HOST=smtp.gmail.com
GMAIL_SMTP_PORT=587

# RunPod Configuration
RUNPOD_API_KEY=${RUNPOD_API_KEY:-demo_key}
RUNPOD_ENDPOINT_ID=${RUNPOD_ENDPOINT_ID:-demo_endpoint}
RUNPOD_GPU_ENABLED=true
RUNPOD_AUTO_SCALING=true
RUNPOD_MAX_INSTANCES=3
RUNPOD_MIN_INSTANCES=1

# Browser Configuration
DISPLAY=:99
CHROME_BIN=/usr/bin/google-chrome-stable
CHROME_OPTIONS=--no-sandbox,--disable-setuid-sandbox,--disable-dev-shm-usage,--disable-gpu,--disable-features=IsolateOrigins,site-per-process

# Social Media Platforms
INSTAGRAM_ENABLED=true
FACEBOOK_ENABLED=true
TWITTER_ENABLED=true
LINKEDIN_ENABLED=true

# Security Configuration
JWT_SECRET=${JWT_SECRET:-your_jwt_secret_key}
JWT_EXPIRES_IN=7d
BCRYPT_ROUNDS=12

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Social Media Rate Limits
INSTAGRAM_MAX_ACTIONS_PER_HOUR=60
FACEBOOK_MAX_ACTIONS_PER_HOUR=60
TWITTER_MAX_ACTIONS_PER_HOUR=300
LINKEDIN_MAX_ACTIONS_PER_HOUR=60

# Content Generation
OPENAI_API_KEY=${OPENAI_API_KEY:-demo_key}
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY:-demo_key}
GOOGLE_AI_API_KEY=${GOOGLE_AI_API_KEY:-demo_key}

# Monitoring
PROMETHEUS_ENABLED=true
GRAFANA_ENABLED=true
HEALTH_CHECK_INTERVAL=30

# Backup Configuration
BACKUP_ENABLED=true
BACKUP_INTERVAL=24h
BACKUP_RETENTION_DAYS=30

# Self-Evolution
EVOLUTION_ENABLED=true
EVOLUTION_INTERVAL=86400
EVOLUTION_THRESHOLD=0.7
EOF

# Create social media configuration
log "Creating social media configuration..."
cat > /opt/maya/config/social-media.json << EOF
{
  "platforms": {
    "instagram": {
      "enabled": true,
      "credentials": {
        "email": "surya.girishad@gmail.com",
        "username": "",
        "backup_email": "surya.girishad@gmail.com"
      },
      "settings": {
        "browser_endpoint": "http://localhost:9222",
        "session_persistence": true,
        "human_behavior_simulation": true,
        "rate_limiting": true,
        "max_actions_per_hour": 60,
        "session_rotation": "daily"
      },
      "automation": {
        "posting": true,
        "story_upload": true,
        "comment_management": true,
        "like_management": true,
        "follow_management": true,
        "dm_management": true,
        "analytics": true
      },
      "content": {
        "post_types": ["photo", "video", "carousel", "story"],
        "max_daily_posts": 3,
        "optimal_posting_times": ["09:00", "15:00", "21:00"],
        "hashtag_strategy": "mixed",
        "engagement_strategy": "authentic_interaction"
      }
    },
    "facebook": {
      "enabled": true,
      "credentials": {
        "email": "surya.girishad@gmail.com",
        "backup_email": "surya.girishad@gmail.com"
      },
      "settings": {
        "browser_endpoint": "http://localhost:9222",
        "session_persistence": true,
        "human_behavior_simulation": true,
        "rate_limiting": true,
        "max_actions_per_hour": 60
      },
      "automation": {
        "page_management": true,
        "group_engagement": true,
        "event_creation": true,
        "messenger": true,
        "posting": true,
        "analytics": true
      }
    },
    "twitter": {
      "enabled": true,
      "credentials": {
        "email": "surya.girishad@gmail.com",
        "backup_email": "surya.girishad@gmail.com"
      },
      "settings": {
        "browser_endpoint": "http://localhost:9222",
        "session_persistence": true,
        "human_behavior_simulation": true,
        "rate_limiting": true,
        "max_actions_per_hour": 300
      },
      "automation": {
        "tweeting": true,
        "threading": true,
        "retweeting": true,
        "liking": true,
        "following": true,
        "trend_monitoring": true,
        "analytics": true
      }
    },
    "linkedin": {
      "enabled": true,
      "credentials": {
        "email": "surya.girishad@gmail.com",
        "password": "",
        "backup_email": "surya.girishad@gmail.com"
      },
      "settings": {
        "browser_endpoint": "http://localhost:9222",
        "session_persistence": true,
        "human_behavior_simulation": true,
        "rate_limiting": true,
        "max_actions_per_hour": 60
      },
      "automation": {
        "posting": true,
        "networking": true,
        "company_page": true,
        "analytics": true
      }
    }
  },
  "security": {
    "rate_limiting": true,
    "human_behavior_simulation": true,
    "session_rotation": "daily",
    "max_actions_per_hour": 60,
    "backup_strategy": "cloud_storage",
    "encryption": "AES-256"
  },
  "analytics": {
    "tracking_enabled": true,
    "metrics_collection": true,
    "performance_monitoring": true,
    "reporting_interval": "daily"
  }
}
EOF

# Create startup script for browser automation
cat > /opt/maya/start-browser.sh << EOF
#!/bin/bash
# Browser automation startup script

# Start Chrome in headless mode with debugging
export DISPLAY=:99
/usr/bin/google-chrome-stable \
    --headless \
    --no-sandbox \
    --disable-setuid-sandbox \
    --disable-dev-shm-usage \
    --disable-gpu \
    --disable-features=IsolateOrigins,site-per-process \
    --disable-blink-features=AutomationControlled \
    --remote-debugging-port=9222 \
    --remote-debugging-address=0.0.0.0 \
    --user-data-dir=/tmp/chrome-profile \
    --disable-web-security \
    --disable-features=TranslateUI \
    --disable-extensions \
    --disable-plugins \
    --disable-images \
    --disable-javascript \
    --disable-default-apps \
    --no-first-run \
    --no-default-browser-check \
    --disable-background-timer-throttling \
    --disable-renderer-backgrounding \
    --disable-backgrounding-occluded-windows \
    --disable-ipc-flooding-protection \
    --password-store=basic \
    --use-mock-keychain \
    --enable-automation \
    --disable-browser-side-navigation \
    --disable-hang-monitor \
    --disable-sync \
    --disable-features=VizDisplayCompositor \
    --disable-features=site-per-process \
    --disable-setuid-sandbox \
    --disable-web-security \
    --disable-features=IsolateOrigins \
    --disable-site-isolation-trials \
    --disable-features=Translate \
    --disable-background-networking \
    --disable-features=OptimizationHints \
    --disable-component-update \
    --disable-features=InterestFeedContentSuggestions \
    --disable-features=CalculateNativeWinOcclusion \
    --disable-features=TranslateUI \
    --disable-features=PrivacySandboxSettings4 \
    --disable-features=AutofillServerCommunication \
    --disable-features=CertificateTransparencyComponentUpdater \
    --disable-features=MediaRouter \
    --disable-features=DialMediaRouteProvider \
    --disable-features=CastMediaRouteProvider \
    --disable-features=CastAllowAllIPs \
    --disable-features=CastStreamingMedia \
    --disable-features=CastStreamingMediaSource \
    --disable-features=CastStreamingMediaSink \
    --disable-features=CastStreamingMediaRoute \
    --disable-features=CastStreamingMediaSource \
    --disable-features=CastStreamingMediaSink \
    --disable-features=CastStreamingMediaRoute \
    --disable-features=CastStreamingMediaSource \
    --disable-features=CastStreamingMediaSink \
    --disable-features=CastStreamingMediaRoute \
    --disable-features=CastStreamingMediaSource \
    --disable-features=CastStreamingMediaSink \
    --disable-features=CastStreamingMediaRoute \
    --disable-features=CastStreamingMediaSource \
    --disable-features=CastStreamingMediaSink \
    --disable-features=CastStreamingMediaRoute &
EOF

chmod +x /opt/maya/start-browser.sh

# Create main application launcher
cat > /opt/maya/start.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 MAYA Orchestrator Starting..."
echo "================================"

# Source environment variables
source /opt/maya/.env

# Create logs directory
mkdir -p logs

# Start virtual display
log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"; }

log "Starting virtual display..."
export DISPLAY=:99
Xvfb :99 -screen 0 1920x1080x24 -ac +extension GLX +render -noreset &
XVFB_PID=$!
sleep 2

# Start browser automation
log "Starting browser automation..."
/opt/maya/start-browser.sh &
BROWSER_PID=$!
sleep 5

# Start main application
log "Starting MAYA main application..."
cd /opt/maya

# Check if main.py exists
if [ -f "src/main.py" ]; then
    log "Found main application, starting FastAPI server..."
    
    # Install dependencies if needed
    if [ ! -d "venv" ]; then
        log "Creating virtual environment..."
        python3 -m venv venv
    fi
    
    source venv/bin/activate
    pip install -r requirements.txt
    
    # Start the main application
    log "Starting FastAPI application on port 8000..."
    python3 src/main.py &
    APP_PID=$!
    
    log "✅ MAYA application started successfully!"
    log "Access points:"
    log "  • Health Check: http://localhost:8000/health"
    log "  • API Docs: http://localhost:8000/docs"
    log "  • API Info: http://localhost:8000/api"
    log "  • RunPod Status: http://localhost:8000/api/runpod/status"
    log "  • Social Media Schedule: POST to /api/social-media/schedule"
    log "  • Analytics: http://localhost:8000/api/analytics/overview"
    log "  • Evolution Status: http://localhost:8000/api/evolution/status"
    
    # Keep the container running
    wait $APP_PID
    
else
    log "❌ Main application not found, starting Python server..."
    python3 maya_server.py
fi

# Cleanup on exit
log "Shutting down MAYA..."
kill $XVFB_PID $BROWSER_PID 2>/dev/null || true
log "✅ MAYA shutdown complete"
EOF

chmod +x /opt/maya/start.sh

# Create requirements.txt for RunPod
cat > /opt/maya/requirements.txt << 'EOF'
# Web Framework
fastapi==0.104.1
uvicorn==0.24.0
pydantic==2.5.0
python-multipart==0.0.6

# Browser Automation
playwright==1.40.0
selenium==4.15.2
webdriver-manager==4.0.1

# Social Media APIs
tweepy==4.14.0
instagrapi==2.0.0
facebook-sdk==3.1.0
linkedin-api==2.1.0

# AI/ML
openai==1.3.7
anthropic==0.7.7
google-generativeai==0.3.2
transformers==4.35.2
torch==2.1.1

# Data processing
pandas==2.1.3
numpy==1.25.2
scikit-learn==1.3.2

# Database
redis==5.0.1
sqlalchemy==2.0.23
alembic==1.12.1

# Utilities
python-dotenv==1.0.0
requests==2.31.0
aiohttp==3.9.1
aiofiles==23.2.1
celery==5.3.4

# Logging
loguru==0.7.2
structlog==23.2.0

# Security
cryptography==41.0.7
bcrypt==4.1.2

# Monitoring
prometheus-client==0.19.0

# Cloud storage
boto3==1.34.0
google-cloud-storage==2.12.0

# Image processing
pillow==10.1.0
opencv-python==4.8.1.78

# Scheduling
apscheduler==3.10.4
croniter==2.0.1

# Testing
pytest==7.4.3
pytest-asyncio==0.21.1
EOF

# Create deployment script for RunPod
cat > /opt/maya/deploy-runpod.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 MAYA RunPod Deployment Script"
echo "================================"
echo "Deploying to RunPod with GPU acceleration"
echo "Gmail: surya.girishad@gmail.com"
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

log "Starting MAYA RunPod deployment..."

# Validate environment
if [ -z "$RUNPOD_API_KEY" ]; then
    error "RUNPOD_API_KEY not set. Please set: export RUNPOD_API_KEY=your_api_key"
fi

# Create deployment package
log "Creating deployment package..."

# Create deployment manifest
cat > deployment-manifest.json << 'EOF'
{
  "name": "maya-orchestrator",
  "version": "1.0.0",
  "description": "Self-evolving digital marketing agent with browser automation",
  "author": "Surya Girishad",
  "email": "surya.girishad@gmail.com",
  "features": [
    "Social Media Automation",
    "Browser Automation",
    "AI Content Generation",
    "RunPod GPU Integration",
    "Self-Evolution",
    "Real-time Analytics"
  ],
  "services": {
    "main_app": {
      "type": "fastapi",
      "port": 8000,
      "description": "Main API server"
    },
    "browser_automation": {
      "type": "chrome_headless",
      "port": 9222,
      "description": "Browser automation for social media"
    },
    "gpu_compute": {
      "type": "runpod_gpu",
      "description": "GPU acceleration for AI content"
    }
  },
  "environment": {
    "cuda_version": "12.1",
    "python_version": "3.11",
    "gpu_type": "NVIDIA A4000",
    "memory": "16GB",
    "storage": "100GB"
  }
}
EOF

# Create deployment script
log "Creating deployment script..."
cat > runpod-deploy.py << 'EOF'
#!/usr/bin/env python3
"""
MAYA RunPod Deployment Script
Deploys MAYA to RunPod with GPU acceleration and browser automation
"""

import os
import sys
import json
import time
import requests
from pathlib import Path

def deploy_to_runpod():
    """Deploy MAYA to RunPod"""
    
    api_key = os.getenv('RUNPOD_API_KEY')
    if not api_key:
        print("❌ RUNPOD_API_KEY not set")
        return False
    
    print("🚀 Deploying MAYA to RunPod...")
    
    # Create endpoint configuration
    endpoint_config = {
        "name": "maya-orchestrator",
        "imageName": "runpod/maya-orchestrator:latest",
        "gpuCount": 1,
        "gpuTypeId": "NVIDIA A4000",
        "containerDiskInGb": 100,
        "minVcpuCount": 4,
        "minMemoryInGb": 16,
        "ports": "8000,9222",
        "env": [
            {"key": "GMAIL_USER", "value": "surya.girishad@gmail.com"},
            {"key": "GMAIL_PASS", "value": "Surya@2003"},
            {"key": "RUNPOD_API_KEY", "value": api_key},
            {"key": "NODE_ENV", "value": "production"}
        ],
        "volumeMountPath": "/opt/maya",
        "volumeInGb": 50,
        "allowedCudaVersions": ["12.1"],
        "isPublic": True
    }
    
    # Deploy to RunPod
    response = requests.post(
        "https://api.runpod.io/v2/endpoint",
        headers={"Authorization": f"Bearer {api_key}"},
        json=endpoint_config
    )
    
    if response.status_code == 200:
        result = response.json()
        print("✅ MAYA deployed to RunPod successfully!")
        print(f"Endpoint ID: {result.get('id', 'unknown')}")
        print(f"Status: {result.get('status', 'unknown')}")
        return True
    else:
        print(f"❌ Deployment failed: {response.status_code}")
        print(response.text)
        return False

if __name__ == "__main__":
    success = deploy_to_runpod()
    sys.exit(0 if success else 1)
EOF

chmod +x runpod-deploy.py

# Deploy to RunPod
log "Deploying to RunPod..."
python3 runpod-deploy.py

if [ $? -eq 0 ]; then
    log "✅ MAYA successfully deployed to RunPod!"
    log ""
    log "🎯 Your deployment is ready!"
    log "MAYA will now:"
    log "  • Manage your social media accounts 24/7"
    log "  • Generate AI content using GPU acceleration"
    log "  • Self-evolve based on performance"
    log "  • Handle Instagram, Facebook, Twitter, LinkedIn"
    log "  • Provide real-time analytics"
    log ""
    log "🚀 Your self-evolving digital marketing agent is live!"
else
    error "❌ Deployment failed"
fi
EOF

chmod +x /opt/maya/deploy-runpod.sh

# Create final deployment script
cat > deploy-final.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 MAYA Final Deployment to RunPod"
echo "=================================="
echo "Deploying with browser automation and GPU acceleration"
echo "Gmail: surya.girishad@gmail.com"
echo "=================================="

# Execute the deployment
cd /opt/maya
./deploy-runpod.sh

echo ""
echo "🎉 MAYA deployment completed!"
echo "Your self-evolving digital marketing agent is ready!"
echo "Access your agent through the RunPod endpoint once deployed."
EOF

chmod +x deploy-final.sh

log "✅ RunPod deployment package created successfully!"
log ""
log "🎯 Ready to deploy to RunPod!"
log ""
log "Next steps:"
log "1. Set your RunPod API key: export RUNPOD_API_KEY=your_key"
log "2. Run deployment: ./deploy-final.sh"
log "3. Access your agent through the RunPod endpoint"
log "4. Configure social media accounts via the web interface"
log ""
log "🚀 Your self-evolving digital marketing agent is ready for the cloud!"