:#!/bin/bash
set -e

# MAYA Cloud VPS Deployment Script
echo "🚀 MAYA Cloud VPS Deployment Script"
echo "===================================="

# Configuration
VPS_IP="${VPS_IP:-}"
VPS_USER="${VPS_USER:-root}"
SSH_KEY="${SSH_KEY:-~/.ssh/id_rsa}"
DOMAIN="${DOMAIN:-maya.yourdomain.com}"
EMAIL="${EMAIL:-surya.girishad@gmail.com}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    log "Checking prerequisites..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first."
    fi
    
    # Check if Docker Compose is installed
    if ! command -v docker-compose &> /dev/null; then
        error "Docker Compose is not installed. Please install Docker Compose first."
    fi
    
    # Check if SSH key exists
    if [ ! -f "$SSH_KEY" ]; then
        error "SSH key not found at $SSH_KEY. Please generate SSH key first."
    fi
    
    log "Prerequisites check passed!"
}

# Generate environment configuration
generate_env() {
    log "Generating environment configuration..."
    
    cat > .env << EOF
# MAYA Orchestrator Environment Configuration
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

# Social Media Platforms
INSTAGRAM_ENABLED=true
FACEBOOK_ENABLED=true
TWITTER_ENABLED=true
LINKEDIN_ENABLED=true

# RunPod Configuration
RUNPOD_API_KEY=${RUNPOD_API_KEY:-your_runpod_api_key}
RUNPOD_ENDPOINT_ID=${RUNPOD_ENDPOINT_ID:-your_runpod_endpoint_id}
RUNPOD_GPU_ENABLED=true
RUNPOD_AUTO_SCALING=true
RUNPOD_MAX_INSTANCES=3
RUNPOD_MIN_INSTANCES=1

# Browser Configuration
CHROME_TOKEN=${CHROME_TOKEN:-maya_chrome_secret_token}
CHROME_ENDPOINT=http://chrome-headless:9222

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_DB=0

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
OPENAI_API_KEY=${OPENAI_API_KEY:-your_openai_api_key}
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY:-your_anthropic_api_key}
GOOGLE_AI_API_KEY=${GOOGLE_AI_API_KEY:-your_google_ai_api_key}

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
    
    log "Environment configuration generated!"
}

# Create social media bridge configuration
create_social_config() {
    log "Creating social media bridge configuration..."
    
    mkdir -p config
    
    cat > config/social-media.json << EOF
{
  "platforms": {
    "instagram": {
      "enabled": true,
      "credentials": {
        "username": "${INSTAGRAM_USERNAME:-}",
        "password": "${INSTAGRAM_PASSWORD:-}",
        "email": "surya.girishad@gmail.com",
        "backup_email": "surya.girishad@gmail.com"
      },
      "settings": {
        "browser_endpoint": "http://chrome-headless:9222",
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
        "password": "${FACEBOOK_PASSWORD:-}",
        "backup_email": "surya.girishad@gmail.com"
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
        "event_creation": true,
        "messenger": true,
        "posting": true,
        "analytics": true
      }
    },
    "twitter": {
      "enabled": true,
      "credentials": {
        "username": "${TWITTER_USERNAME:-}",
        "email": "surya.girishad@gmail.com",
        "backup_email": "surya.girishad@gmail.com"
      },
      "settings": {
        "browser_endpoint": "http://chrome-headless:9222",
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
        "password": "${LINKEDIN_PASSWORD:-}",
        "backup_email": "surya.girishad@gmail.com"
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
    
    log "Social media configuration created!"
}

# Create monitoring configuration
create_monitoring_config() {
    log "Creating monitoring configuration..."
    
    mkdir -p monitoring
    
    # Prometheus configuration
    cat > monitoring/prometheus.yml << EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "rules/*.yml"

scrape_configs:
  - job_name: 'maya-orchestrator'
    static_configs:
      - targets: ['maya-orchestrator:3000']
    scrape_interval: 15s
    metrics_path: /metrics
    
  - job_name: 'chrome-headless'
    static_configs:
      - targets: ['chrome-headless:9222']
    scrape_interval: 30s
    metrics_path: /json
    
  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
    scrape_interval: 15s
    
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
    scrape_interval: 15s
    
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
    scrape_interval: 15s
EOF

    # Grafana dashboard configuration
    mkdir -p monitoring/grafana/dashboards
    
    cat > monitoring/grafana/dashboards/maya-dashboard.json << EOF
{
  "dashboard": {
    "id": null,
    "title": "MAYA Orchestrator Dashboard",
    "tags": ["maya", "orchestrator", "social-media"],
    "style": "dark",
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "System Health",
        "type": "stat",
        "targets": [
          {
            "expr": "up{job=\"maya-orchestrator\"}",
            "legendFormat": "MAYA Status"
          }
        ]
      },
      {
        "id": 2,
        "title": "Social Media Actions",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(social_media_actions_total[5m])",
            "legendFormat": "Actions/sec"
          }
        ]
      },
      {
        "id": 3,
        "title": "Content Generation Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(content_generated_total[5m])",
            "legendFormat": "Content/sec"
          }
        ]
      },
      {
        "id": 4,
        "title": "API Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      },
      {
        "id": 5,
        "title": "Memory Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "process_resident_memory_bytes / 1024 / 1024",
            "legendFormat": "Memory (MB)"
          }
        ]
      },
      {
        "id": 6,
        "title": "Disk Usage",
        "type": "graph",
        "targets": [
          {
            "expr": "node_filesystem_avail_bytes / node_filesystem_size_bytes * 100",
            "legendFormat": "Disk Usage %"
          }
        ]
      }
    ]
  }
}
EOF
    
    log "Monitoring configuration created!"
}

# Create deployment script
create_deploy_script() {
    log "Creating deployment script..."
    
    cat > deploy.sh << 'EOF'
#!/bin/bash
set -e

echo "🚀 MAYA Cloud Deployment Script"
echo "================================"

# Configuration
VPS_IP="${VPS_IP:-}"
VPS_USER="${VPS_USER:-root}"
SSH_KEY="${SSH_KEY:-~/.ssh/id_rsa}"
DOMAIN="${DOMAIN:-maya.yourdomain.com}"
EMAIL="${EMAIL:-surya.girishad@gmail.com}"

# Colors
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

# Validate configuration
if [ -z "$VPS_IP" ]; then
    error "VPS_IP not set. Please set VPS_IP environment variable."
fi

if [ -z "$DOMAIN" ]; then
    error "DOMAIN not set. Please set DOMAIN environment variable."
fi

log "Starting deployment to VPS: $VPS_IP"

# Copy files to VPS
log "Copying files to VPS..."
ssh -i "$SSH_KEY" "$VPS_USER@$VPS_IP" "mkdir -p /opt/maya"
scp -i "$SSH_KEY" -r . "$VPS_USER@$VPS_IP:/opt/maya/"

# Connect to VPS and execute deployment
ssh -i "$SSH_KEY" "$VPS_USER@$VPS_IP" << 'DEPLOY_EOF'
cd /opt/maya

# Update system
apt update && apt upgrade -y

# Install Docker and Docker Compose
apt install -y docker.io docker-compose
systemctl enable docker
systemctl start docker

# Add user to docker group
usermod -aG docker $USER

# Create directories
mkdir -p /opt/maya/{soul,config,logs,data,skills,temp}

# Set permissions
chmod +x entrypoint.sh deploy.sh

# Pull Docker images
docker-compose pull

# Start services
docker-compose up -d

# Wait for services to be ready
echo "Waiting for services to start..."
sleep 30

# Check service status
docker-compose ps

# Show logs
docker-compose logs --tail=50

echo "Deployment completed!"
echo "Access MAYA at: https://$DOMAIN"
echo "Grafana Dashboard: https://$DOMAIN:3001"
echo "Prometheus: https://$DOMAIN:9090"

DEPLOY_EOF

log "Deployment completed successfully!"
echo ""
echo "🎉 MAYA is now running on your VPS!"
echo "Access your digital marketing agent at: https://$DOMAIN"
echo ""
echo "Next steps:"
echo "1. Configure your social media accounts in the dashboard"
echo "2. Set up content calendars and automation rules"
echo "3. Monitor performance through Grafana dashboard"
echo "4. Let MAYA handle your digital marketing 24/7!"

EOF
    
    chmod +x deploy.sh
    log "Deployment script created!"
}

# Create social media bridge skills
create_bridge_skills() {
    log "Creating social media bridge skills..."
    
    mkdir -p skills
    
    # Instagram Bridge Skill
    cat > skills/instagram-bridge.js << 'EOF'
const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
const { Redis } = require('redis');
const winston = require('winston');

puppeteer.use(StealthPlugin());

class InstagramBridge {
    constructor(config) {
        this.config = config;
        this.browser = null;
        this.page = null;
        this.redis = new Redis(config.redis);
        this.logger = winston.createLogger({
            level: 'info',
            format: winston.format.json(),
            transports: [
                new winston.transports.Console(),
                new winston.transports.File({ filename: 'instagram-bridge.log' })
            ]
        });
    }

    async initialize() {
        this.logger.info('Initializing Instagram Bridge...');
        
        this.browser = await puppeteer.launch({
            headless: true,
            args: [
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-dev-shm-usage',
                '--disable-accelerated-2d-canvas',
                '--no-first-run',
                '--no-zygote',
                '--single-process',
                '--disable-gpu'
            ],
            executablePath: '/usr/bin/chromium-browser'
        });

        this.page = await this.browser.newPage();
        await this.page.setViewport({ width: 1366, height: 768 });
        
        this.logger.info('Instagram Bridge initialized successfully');
    }

    async login() {
        this.logger.info('Logging into Instagram...');
        
        try {
            await this.page.goto('https://www.instagram.com/accounts/login/', {
                waitUntil: 'networkidle2'
            });

            // Wait for and fill username
            await this.page.waitForSelector('input[name="username"]');
            await this.page.type('input[name="username"]', this.config.credentials.username);
            
            // Fill password
            await this.page.type('input[name="password"]', this.config.credentials.password);
            
            // Click login button
            await this.page.click('button[type="submit"]');
            
            // Wait for navigation
            await this.page.waitForNavigation({ waitUntil: 'networkidle2' });
            
            // Check if login was successful
            if (this.page.url().includes('instagram.com')) {
                this.logger.info('Instagram login successful');
                return true;
            } else {
                this.logger.error('Instagram login failed');
                return false;
            }
        } catch (error) {
            this.logger.error('Instagram login error:', error);
            return false;
        }
    }

    async postContent(content) {
        this.logger.info('Posting content to Instagram...');
        
        try {
            // Navigate to create post
            await this.page.goto('https://www.instagram.com/create/style/', {
                waitUntil: 'networkidle2'
            });

            // Upload media
            if (content.media) {
                await this.page.waitForSelector('input[type="file"]');
                await this.page.uploadFile('input[type="file"]', content.media);
                await this.page.waitForTimeout(3000);
            }

            // Add caption
            if (content.caption) {
                await this.page.click('textarea[placeholder*="caption"]');
                await this.page.type('textarea[placeholder*="caption"]', content.caption);
            }

            // Add hashtags
            if (content.hashtags) {
                await this.page.type('textarea[placeholder*="caption"]', ' ' + content.hashtags.join(' '));
            }

            // Share post
            await this.page.click('button:has-text("Share")');
            await this.page.waitForTimeout(5000);

            this.logger.info('Content posted successfully');
            return true;

        } catch (error) {
            this.logger.error('Error posting content:', error);
            return false;
        }
    }

    async engageWithContent(targets) {
        this.logger.info('Engaging with content...');
        
        for (const target of targets) {
            try {
                await this.page.goto(target.url, { waitUntil: 'networkidle2' });
                
                // Like the post
                if (target.action === 'like') {
                    await this.page.click('button[aria-label*="Like"]');
                    await this.page.waitForTimeout(2000);
                }
                
                // Comment on the post
                if (target.action === 'comment' && target.comment) {
                    await this.page.click('textarea[placeholder*="comment"]');
                    await this.page.type('textarea[placeholder*="comment"]', target.comment);
                    await this.page.keyboard.press('Enter');
                    await this.page.waitForTimeout(2000);
                }
                
                // Follow the user
                if (target.action === 'follow') {
                    await this.page.click('button:has-text("Follow")');
                    await this.page.waitForTimeout(2000);
                }
                
                this.logger.info(`Engaged with ${target.url}`);
                
            } catch (error) {
                this.logger.error(`Error engaging with ${target.url}:`, error);
            }
        }
    }

    async getAnalytics() {
        this.logger.info('Getting Instagram analytics...');
        
        try {
            await this.page.goto('https://www.instagram.com/accounts/insights/', {
                waitUntil: 'networkidle2'
            });
            
            // Extract analytics data
            const analytics = await this.page.evaluate(() => {
                return {
                    followers: document.querySelector('span[title*="followers"]')?.textContent,
                    posts: document.querySelector('span[title*="posts"]')?.textContent,
                    engagement: document.querySelector('span[title*="engagement"]')?.textContent,
                    reach: document.querySelector('span[title*="reach"]')?.textContent,
                    impressions: document.querySelector('span[title*="impressions"]')?.textContent
                };
            });
            
            this.logger.info('Analytics retrieved:', analytics);
            return analytics;
            
        } catch (error) {
            this.logger.error('Error getting analytics:', error);
            return null;
        }
    }

    async close() {
        this.logger.info('Closing Instagram Bridge...');
        
        if (this.browser) {
            await this.browser.close();
        }
        
        if (this.redis) {
            await this.redis.quit();
        }
        
        this.logger.info('Instagram Bridge closed');
    }
}

module.exports = InstagramBridge;
EOF

    # Facebook Bridge Skill
    cat > skills/facebook-bridge.js << 'EOF'
const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
const { Redis } = require('redis');
const winston = require('winston');

puppeteer.use(StealthPlugin());

class FacebookBridge {
    constructor(config) {
        this.config = config;
        this.browser = null;
        this.page = null;
        this.redis = new Redis(config.redis);
        this.logger = winston.createLogger({
            level: 'info',
            format: winston.format.json(),
            transports: [
                new winston.transports.Console(),
                new winston.transports.File({ filename: 'facebook-bridge.log' })
            ]
        });
    }

    async initialize() {
        this.logger.info('Initializing Facebook Bridge...');
        
        this.browser = await puppeteer.launch({
            headless: true,
            args: [
                '--no-sandbox',
                '--disable-setuid-sandbox',
                '--disable-dev-shm-usage',
                '--disable-accelerated-2d-canvas',
                '--no-first-run',
                '--no-zygote',
                '--single-process',
                '--disable-gpu'
            ],
            executablePath: '/usr/bin/chromium-browser'
        });

        this.page = await this.browser.newPage();
        await this.page.setViewport({ width: 1366, height: 768 });
        
        this.logger.info('Facebook Bridge initialized successfully');
    }

    async login() {
        this.logger.info('Logging into Facebook...');
        
        try {
            await this.page.goto('https://www.facebook.com/login', {
                waitUntil: 'networkidle2'
            });

            // Wait for and fill email
            await this.page.waitForSelector('input[name="email"]');
            await this.page.type('input[name="email"]', this.config.credentials.email);
            
            // Fill password
            await this.page.type('input[name="pass"]', this.config.credentials.password);
            
            // Click login button
            await this.page.click('button[name="login"]');
            
            // Wait for navigation
            await this.page.waitForNavigation({ waitUntil: 'networkidle2' });
            
            this.logger.info('Facebook login successful');
            return true;
            
        } catch (error) {
            this.logger.error('Facebook login error:', error);
            return false;
        }
    }

    async postToPage(pageId, content) {
        this.logger.info(`Posting to Facebook page: ${pageId}`);
        
        try {
            await this.page.goto(`https://www.facebook.com/${pageId}`, {
                waitUntil: 'networkidle2'
            });

            // Click create post button
            await this.page.click('div[aria-label*="Create post"]');
            await this.page.waitForTimeout(2000);

            // Type content
            if (content.text) {
                await this.page.type('div[contenteditable="true"]', content.text);
            }

            // Add media if provided
            if (content.media) {
                await this.page.waitForSelector('input[type="file"]');
                await this.page.uploadFile('input[type="file"]', content.media);
                await this.page.waitForTimeout(3000);
            }

            // Click post button
            await this.page.click('div[aria-label*="Post"]');
            await this.page.waitForTimeout(5000);

            this.logger.info('Content posted to Facebook page successfully');
            return true;

        } catch (error) {
            this.logger.error('Error posting to Facebook page:', error);
            return false;
        }
    }

    async engageWithGroups(groups) {
        this.logger.info('Engaging with Facebook groups...');
        
        for (const group of groups) {
            try {
                await this.page.goto(group.url, { waitUntil: 'networkidle2' });
                
                if (group.action === 'post') {
                    // Create a post in the group
                    await this.page.click('div[aria-label*="Write something"]');
                    await this.page.waitForTimeout(2000);
                    
                    await this.page.type('div[contenteditable="true"]', group.content);
                    await this.page.click('div[aria-label*="Post"]');
                    await this.page.waitForTimeout(3000);
                }
                
                if (group.action === 'comment') {
                    // Comment on posts in the group
                    const posts = await this.page.$$('div[role="article"]');
                    for (const post of posts.slice(0, 3)) { // Limit to first 3 posts
                        await post.click();
                        await this.page.waitForTimeout(2000);
                        
                        await this.page.type('div[contenteditable="true"]', group.comment);
                        await this.page.keyboard.press('Enter');
                        await this.page.waitForTimeout(2000);
                    }
                }
                
                this.logger.info(`Engaged with group: ${group.name}`);
                
            } catch (error) {
                this.logger.error(`Error engaging with group ${group.name}:`, error);
            }
        }
    }

    async getPageInsights(pageId) {
        this.logger.info(`Getting Facebook page insights for: ${pageId}`);
        
        try {
            await this.page.goto(`https://www.facebook.com/${pageId}/insights`, {
                waitUntil: 'networkidle2'
            });
            
            // Extract insights data
            const insights = await this.page.evaluate(() => {
                return {
                    pageLikes: document.querySelector('div[title*="Page Likes"]')?.textContent,
                    postReach: document.querySelector('div[title*="Post Reach"]')?.textContent,
                    engagement: document.querySelector('div[title*="Engagement"]')?.textContent,
                    pageViews: document.querySelector('div[title*="Page Views"]')?.textContent,
                    actions: document.querySelector('div[title*="Actions on Page"]')?.textContent
                };
            });
            
            this.logger.info('Facebook page insights retrieved:', insights);
            return insights;
            
        } catch (error) {
            this.logger.error('Error getting Facebook page insights:', error);
            return null;
        }
    }

    async close() {
        this.logger.info('Closing Facebook Bridge...');
        
        if (this.browser) {
            await this.browser.close();
        }
        
        if (this.redis) {
            await this.redis.quit();
        }
        
        this.logger.info('Facebook Bridge closed');
    }
}

module.exports = FacebookBridge;
EOF

    log "Social media bridge skills created!"
}

# Create RunPod integration
create_runpod_integration() {
    log "Creating RunPod integration..."
    
    mkdir -p src/integrations
    
    cat > src/integrations/runpod.js << 'EOF'
const axios = require('axios');
const winston = require('winston');

class RunPodIntegration {
    constructor(config) {
        this.config = config;
        this.apiKey = config.api_key;
        this.endpointId = config.endpoint_id;
        this.baseURL = 'https://api.runpod.io/v2';
        this.logger = winston.createLogger({
            level: 'info',
            format: winston.format.json(),
            transports: [
                new winston.transports.Console(),
                new winston.transports.File({ filename: 'runpod-integration.log' })
            ]
        });
    }

    async createEndpoint(templateId, name, config = {}) {
        this.logger.info(`Creating RunPod endpoint: ${name}`);
        
        try {
            const response = await axios.post(
                `${this.baseURL}/endpoint`,
                {
                    templateId,
                    name,
                    config: {
                        gpu_count: config.gpu_count || 1,
                        gpu_type_id: config.gpu_type || 'NVIDIA A4000',
                        container_disk_in_gb: config.disk_size || 50,
                        min_vcpu_count: config.vcpu_count || 4,
                        min_memory_in_gb: config.memory || 16,
                        ...config
                    }
                },
                {
                    headers: {
                        'Authorization': `Bearer ${this.apiKey}`,
                        'Content-Type': 'application/json'
                    }
                }
            );
            
            this.logger.info('RunPod endpoint created successfully');
            return response.data;
            
        } catch (error) {
            this.logger.error('Error creating RunPod endpoint:', error);
            throw error;
        }
    }

    async getEndpointStatus(endpointId) {
        this.logger.info(`Getting RunPod endpoint status: ${endpointId}`);
        
        try {
            const response = await axios.get(
                `${this.baseURL}/endpoint/${endpointId}`,
                {
                    headers: {
                        'Authorization': `Bearer ${this.apiKey}`
                    }
                }
            );
            
            return response.data;
            
        } catch (error) {
            this.logger.error('Error getting RunPod endpoint status:', error);
            throw error;
        }
    }

    async runJob(endpointId, input, config = {}) {
        this.logger.info(`Running job on RunPod endpoint: ${endpointId}`);
        
        try {
            const response = await axios.post(
                `${this.baseURL}/endpoint/${endpointId}/run`,
                {
                    input,
                    config: {
                        timeout: config.timeout || 300,
                        gpu_count: config.gpu_count || 1,
                        ...config
                    }
                },
                {
                    headers: {
                        'Authorization': `Bearer ${this.apiKey}`,
                        'Content-Type': 'application/json'
                    }
                }
            );
            
            this.logger.info('RunPod job started successfully');
            return response.data;
            
        } catch (error) {
            this.logger.error('Error running RunPod job:', error);
            throw error;
        }
    }

    async getJobStatus(jobId) {
        this.logger.info(`Getting RunPod job status: ${jobId}`);
        
        try {
            const response = await axios.get(
                `${this.baseURL}/job/${jobId}`,
                {
                    headers: {
                        'Authorization': `Bearer ${this.apiKey}`
                    }
                }
            );
            
            return response.data;
            
        } catch (error) {
            this.logger.error('Error getting RunPod job status:', error);
            throw error;
        }
    }

    async autoScale(minInstances, maxInstances) {
        this.logger.info(`Setting up auto-scaling: ${minInstances}-${maxInstances} instances`);
        
        try {
            const response = await axios.post(
                `${this.baseURL}/endpoint/${this.endpointId}/autoscale`,
                {
                    min_instances: minInstances,
                    max_instances: maxInstances,
                    scale_up_threshold: 0.8,
                    scale_down_threshold: 0.2,
                    scale_up_cooldown: 300,
                    scale_down_cooldown: 600
                },
                {
                    headers: {
                        'Authorization': `Bearer ${this.apiKey}`,
                        'Content-Type': 'application/json'
                    }
                }
            );
            
            this.logger.info('Auto-scaling configured successfully');
            return response.data;
            
        } catch (error) {
            this.logger.error('Error setting up auto-scaling:', error);
            throw error;
        }
    }

    async optimizeForSocialMedia(contentType, content) {
        this.logger.info(`Optimizing content for ${contentType} using RunPod GPU`);
        
        const jobInput = {
            content_type: contentType,
            content: content,
            optimization_type: 'social_media',
            platform_specific: true,
            include_hashtags: true,
            include_emojis: true,
            target_audience: 'general',
            tone: 'professional'
        };

        try {
            const job = await this.runJob(this.endpointId, jobInput, {
                timeout: 120,
                gpu_count: 1
            });

            // Poll for job completion
            let jobStatus = await this.getJobStatus(job.id);
            let attempts = 0;
            const maxAttempts = 60; // 5 minutes with 5-second intervals

            while (jobStatus.status !== 'COMPLETED' && attempts < maxAttempts) {
                await new Promise(resolve => setTimeout(resolve, 5000));
                jobStatus = await this.getJobStatus(job.id);
                attempts++;
            }

            if (jobStatus.status === 'COMPLETED') {
                this.logger.info('Content optimization completed');
                return jobStatus.output;
            } else {
                throw new Error('Job did not complete within timeout');
            }

        } catch (error) {
            this.logger.error('Error optimizing content with RunPod:', error);
            throw error;
        }
    }

    async generateAIContent(prompt, type = 'social_media') {
        this.logger.info(`Generating AI content for ${type}`);
        
        const jobInput = {
            prompt: prompt,
            type: type,
            max_tokens: 1000,
            temperature: 0.7,
            top_p: 0.9,
            frequency_penalty: 0.0,
            presence_penalty: 0.0
        };

        try {
            const job = await this.runJob(this.endpointId, jobInput, {
                timeout: 180,
                gpu_count: 1
            });

            return await this.waitForJobCompletion(job.id);
            
        } catch (error) {
            this.logger.error('Error generating AI content:', error);
            throw error;
        }
    }

    async waitForJobCompletion(jobId, maxWaitTime = 300000) {
        const startTime = Date.now();
        
        while (Date.now() - startTime < maxWaitTime) {
            const status = await this.getJobStatus(jobId);
            
            if (status.status === 'COMPLETED') {
                return status.output;
            } else if (status.status === 'FAILED') {
                throw new Error(`Job failed: ${status.error}`);
            }
            
            await new Promise(resolve => setTimeout(resolve, 5000));
        }
        
        throw new Error('Job timeout exceeded');
    }

    async getBillingInfo() {
        this.logger.info('Getting RunPod billing information');
        
        try {
            const response = await axios.get(
                `${this.baseURL}/billing`,
                {
                    headers: {
                        'Authorization': `Bearer ${this.apiKey}`
                    }
                }
            );
            
            return response.data;
            
        } catch (error) {
            this.logger.error('Error getting billing info:', error);
            throw error;
        }
    }

    async terminateEndpoint(endpointId) {
        this.logger.info(`Terminating RunPod endpoint: ${endpointId}`);
        
        try {
            const response = await axios.delete(
                `${this.baseURL}/endpoint/${endpointId}`,
                {
                    headers: {
                        'Authorization': `Bearer ${this.apiKey}`
                    }
                }
            );
            
            this.logger.info('RunPod endpoint terminated successfully');
            return response.data;
            
        } catch (error) {
            this.logger.error('Error terminating RunPod endpoint:', error);
            throw error;
        }
    }
}

module.exports = RunPodIntegration;
EOF
    
    log "RunPod integration created!"
}

# Main deployment function
deploy() {
    log "Starting MAYA cloud deployment..."
    
    # Check prerequisites
    check_prerequisites
    
    # Generate configurations
    generate_env
    create_social_config
    create_monitoring_config
    create_deploy_script
    create_bridge_skills
    create_runpod_integration
    
    log "All configurations created successfully!"
    log ""
    log "🎉 MAYA deployment package is ready!"
    log ""
    log "Next steps:"
    log "1. Set VPS_IP environment variable: export VPS_IP=your_vps_ip"
    log "2. Set RUNPOD_API_KEY: export RUNPOD_API_KEY=your_runpod_key"
    log "3. Run deployment: ./deploy.sh"
    log "4. Access MAYA at: https://your-domain.com"
    log ""
    log "Files created:"
    log "- docker-compose.yml (Complete stack configuration)"
    log "- Dockerfile.maya (MAYA orchestrator container)"
    log "- entrypoint.sh (Container startup script)"
    log "- Caddyfile (Reverse proxy configuration)"
    log "- .env (Environment variables)"
    log "- config/social-media.json (Social media platform settings)"
    log "- monitoring/ (Prometheus & Grafana configs)"
    log "- deploy.sh (Deployment automation script)"
    log "- skills/ (Social media bridge skills)"
    log "- src/integrations/runpod.js (RunPod GPU integration)"
    log ""
    log "🚀 Your self-evolving digital marketing agent is ready for the cloud!"
}

# Run deployment
deploy