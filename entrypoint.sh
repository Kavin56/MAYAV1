:#!/bin/sh
set -e

# MAYA Orchestrator Entrypoint Script
echo "🚀 Starting MAYA Orchestrator..."

# Wait for Redis to be ready
echo "⏳ Waiting for Redis..."
while ! nc -z redis 6379; do
  sleep 1
done
echo "✅ Redis is ready"

# Wait for Chrome to be ready
echo "⏳ Waiting for Chrome Headless..."
while ! nc -z chrome-headless 9222; do
  sleep 1
done
echo "✅ Chrome Headless is ready"

# Create necessary directories
echo "📁 Creating directory structure..."
mkdir -p /opt/maya/{soul,config,logs,data,skills,temp}

# Set up permissions
echo "🔐 Setting permissions..."
chmod 755 /opt/maya/{soul,config,logs,data,skills,temp}

# Initialize MAYA soul if not exists
if [ ! -f "/opt/maya/soul/.opencode/opencode.json" ]; then
    echo "🌟 Initializing MAYA soul..."
    mkdir -p /opt/maya/soul/.opencode
    cat > /opt/maya/soul/.opencode/opencode.json << EOF
{
  "version": "1.0.0",
  "name": "MAYA-Soul",
  "description": "Self-evolving digital marketing agent",
  "author": "Surya Girishad",
  "email": "surya.girishad@gmail.com",
  "settings": {
    "heartbeat_interval": 21600,
    "self_evolution": true,
    "social_media_bridge": true,
    "gmail_user": "surya.girishad@gmail.com",
    "runpod_enabled": true
  },
  "skills": [
    "social-media-bridge",
    "content-creation",
    "analytics-tracking",
    "self-evolution"
  ],
  "memory": {
    "type": "redis",
    "host": "redis",
    "port": 6379,
    "db": 0
  }
}
EOF
fi

# Set up social media bridge configuration
if [ ! -f "/opt/maya/config/social-media.json" ]; then
    echo "🔗 Setting up social media bridge..."
    cat > /opt/maya/config/social-media.json << EOF
{
  "platforms": {
    "instagram": {
      "enabled": true,
      "browser_endpoint": "http://chrome-headless:9222",
      "session_persistence": true,
      "automation": {
        "posting": true,
        "story_upload": true,
        "engagement": true,
        "analytics": true
      }
    },
    "facebook": {
      "enabled": true,
      "browser_endpoint": "http://chrome-headless:9222",
      "session_persistence": true,
      "automation": {
        "posting": true,
        "page_management": true,
        "group_engagement": true,
        "messenger": true
      }
    },
    "twitter": {
      "enabled": true,
      "browser_endpoint": "http://chrome-headless:9222",
      "session_persistence": true,
      "automation": {
        "tweeting": true,
        "threading": true,
        "engagement": true,
        "trend_monitoring": true
      }
    },
    "linkedin": {
      "enabled": true,
      "browser_endpoint": "http://chrome-headless:9222",
      "session_persistence": true,
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
    "max_actions_per_hour": 60
  }
}
EOF
fi

# Set up RunPod integration
if [ ! -z "$RUNPOD_API_KEY" ] && [ ! -z "$RUNPOD_ENDPOINT_ID" ]; then
    echo "☁️ Configuring RunPod integration..."
    cat > /opt/maya/config/runpod.json << EOF
{
  "api_key": "$RUNPOD_API_KEY",
  "endpoint_id": "$RUNPOD_ENDPOINT_ID",
  "gpu_enabled": true,
  "auto_scaling": true,
  "max_instances": 3,
  "min_instances": 1,
  "idle_timeout": 300,
  "gpu_type": "NVIDIA A4000"
}
EOF
fi

# Set up heartbeat configuration
echo "💓 Configuring heartbeat..."
cat > /opt/maya/config/heartbeat.json << EOF
{
  "interval": ${MAYA_HEARTBEAT_INTERVAL:-21600},
  "tasks": [
    {
      "name": "social_media_heartbeat",
      "enabled": true,
      "schedule": "0 */6 * * *",
      "actions": [
        "check_platform_health",
        "update_analytics",
        "optimize_content_strategy",
        "evolve_skills"
      ]
    },
    {
      "name": "content_synthesis",
      "enabled": true,
      "schedule": "0 9,15,21 * * *",
      "actions": [
        "generate_content_ideas",
        "create_posting_schedule",
        "research_trending_topics",
        "optimize_hashtags"
      ]
    },
    {
      "name": "self_evolution",
      "enabled": true,
      "schedule": "0 0 * * *",
      "actions": [
        "analyze_performance",
        "identify_gaps",
        "synthesize_new_skills",
        "update_strategies"
      ]
    }
  ]
}
EOF

# Start the application
echo "🎯 Starting MAYA application..."
exec "$@"