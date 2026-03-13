:# MAYA Cloud VPS Deployment - Quick Start Guide

## 🚀 Deployment Package Created!

I've created a complete deployment package for MAYA with RunPod integration. Here's what's been generated:

### 📁 **Files Created:**

1. **`docker-compose.yml`** - Complete multi-service orchestration
2. **`Dockerfile.maya`** - MAYA orchestrator container definition  
3. **`entrypoint.sh`** - Container initialization script
4. **`Caddyfile`** - Reverse proxy with SSL configuration
5. **`deploy.sh`** - Automated deployment script
6. **`package.json`** - Node.js dependencies and scripts

### 🎯 **Services Included:**

- **MAYA Orchestrator** - Main application server
- **Chrome Headless** - Browser automation for social media
- **Redis** - Session management and caching
- **Caddy** - SSL reverse proxy
- **Prometheus** - Metrics collection
- **Grafana** - Dashboard visualization
- **MAYA Heartbeat** - Self-evolution scheduler

### 🔧 **RunPod Integration Features:**

- **GPU Acceleration** - Content generation and AI processing
- **Auto-scaling** - Dynamic instance management
- **Cost Optimization** - Pay-per-use pricing model
- **High Availability** - Multiple instance support

### 🔐 **Security Features:**

- **SSL/TLS Encryption** - All traffic encrypted
- **Rate Limiting** - API protection
- **Session Management** - Secure authentication
- **Input Validation** - Data sanitization
- **Audit Logging** - Activity tracking

## 📋 **Next Steps:**

### **1. Environment Setup**
```bash
# Set required environment variables
export VPS_IP="your_vps_ip_address"
export DOMAIN="your_domain.com"
export RUNPOD_API_KEY="your_runpod_api_key"
export RUNPOD_ENDPOINT_ID="your_runpod_endpoint_id"

# Optional: Set social media credentials
export INSTAGRAM_USERNAME="your_instagram_username"
export INSTAGRAM_PASSWORD="your_instagram_password"
export FACEBOOK_PASSWORD="your_facebook_password"
export TWITTER_USERNAME="your_twitter_username"
export LINKEDIN_PASSWORD="your_linkedin_password"
```

### **2. VPS Preparation**
```bash
# On your VPS (Ubuntu 24.04 recommended)
sudo apt update && sudo apt upgrade -y
sudo apt install -y docker.io docker-compose curl git

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### **3. SSL Certificate Setup**
```bash
# Install Certbot for SSL
sudo apt install -y certbot
sudo certbot certonly --standalone -d your_domain.com
```

### **4. Deploy MAYA**
```bash
# Run the deployment script
chmod +x deploy.sh
./deploy.sh
```

### **5. Verify Deployment**
```bash
# Check service status
docker-compose ps

# View logs
docker-compose logs -f

# Test health endpoint
curl -f http://localhost:3000/health
```

## 🌐 **Access Points:**

- **Main Application**: `https://your-domain.com`
- **Grafana Dashboard**: `https://your-domain.com:3001`
- **Prometheus Metrics**: `https://your-domain.com:9090`
- **API Documentation**: `https://your-domain.com/api/docs`

## 📊 **Monitoring & Maintenance:**

### **Health Checks**
- Every 30 seconds: Service health monitoring
- Every 6 hours: Self-evolution heartbeat
- Daily: Performance analytics
- Weekly: Security audits

### **Backup Strategy**
- Hourly: Application data snapshots
- Daily: Full system backups
- Weekly: Off-site archive storage

## 🚨 **Troubleshooting:**

### **Common Issues:**
1. **Port Conflicts**: Ensure ports 80, 443, 3000, 9090, 3001 are available
2. **SSL Certificate**: Verify domain ownership and certificate validity
3. **Docker Permissions**: Check user is in docker group
4. **Memory Issues**: Ensure VPS has minimum 4GB RAM

### **Support Commands:**
```bash
# Restart all services
docker-compose restart

# View specific service logs
docker-compose logs maya-orchestrator

# Rebuild and redeploy
docker-compose down && docker-compose up -d --build

# Check resource usage
docker stats
```

## 🎯 **Ready for Social Media Automation!**

Once deployed, MAYA will:
- ✅ Manage Instagram, Facebook, Twitter, LinkedIn
- ✅ Generate AI-powered content using RunPod GPU
- ✅ Schedule posts automatically
- ✅ Engage with audiences authentically
- ✅ Track analytics and performance
- ✅ Self-evolve based on results
- ✅ Run 24/7 without intervention

## 📞 **Support:**

For issues or questions:
- Email: surya.girishad@gmail.com
- Check logs: `docker-compose logs`
- Health status: `curl https://your-domain.com/health`

---

**🎉 Your self-evolving digital marketing agent is ready for the cloud!**
**Deploy and let MAYA handle your social media marketing 24/7!**