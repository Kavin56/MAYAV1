:const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const winston = require('winston');
const Redis = require('redis');
const cron = require('node-cron');
const path = require('path');
const fs = require('fs');

// Configure logging
const logger = winston.createLogger({
    level: process.env.MAYA_LOG_LEVEL || 'info',
    format: winston.format.combine(
        winston.format.timestamp(),
        winston.format.errors({ stack: true }),
        winston.format.json()
    ),
    defaultMeta: { service: 'maya-orchestrator' },
    transports: [
        new winston.transports.Console({
            format: winston.format.combine(
                winston.format.colorize(),
                winston.format.simple()
            )
        }),
        new winston.transports.File({ 
            filename: 'logs/error.log', 
            level: 'error',
            maxsize: 5242880, // 5MB
            maxFiles: 5
        }),
        new winston.transports.File({ 
            filename: 'logs/combined.log',
            maxsize: 5242880, // 5MB
            maxFiles: 5
        })
    ]
});

// Initialize Redis client
const redis = Redis.createClient({
    host: process.env.REDIS_HOST || 'redis',
    port: process.env.REDIS_PORT || 6379
});

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
app.use(helmet());
app.use(cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
    credentials: true
}));

// Rate limiting
app.use(rateLimit({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100
}));

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health check
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        version: '1.0.0',
        uptime: process.uptime()
    });
});

// API routes
app.get('/api', (req, res) => {
    res.json({
        message: 'MAYA Orchestrator API',
        version: '1.0.0',
        endpoints: [
            '/health',
            '/api/social-media',
            '/api/analytics',
            '/api/evolution',
            '/api/runpod'
        ]
    });
});

app.get('/api/runpod/status', (req, res) => {
    res.json({
        status: 'connected',
        gpu_enabled: true,
        auto_scaling: true,
        max_instances: 3,
        current_instances: 1
    });
});

app.post('/api/runpod/generate', async (req, res) => {
    try {
        const { prompt, content_type } = req.body;
        
        // Simulate RunPod GPU content generation
        const generatedContent = {
            content: `AI-generated content for: ${prompt}`,
            hashtags: ['#AI', '#Generated', '#Marketing'],
            emojis: ['🚀', '💡'],
            tone: 'professional',
            length: 'medium',
            platform_optimized: content_type || 'instagram'
        };
        
        res.json({
            success: true,
            content: generatedContent,
            generated_at: new Date().toISOString()
        });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/social-media/schedule', async (req, res) => {
    try {
        const { platform, content, schedule_time } = req.body;
        
        // Simulate social media scheduling
        const scheduledPost = {
            id: Date.now().toString(),
            platform,
            content,
            schedule_time,
            status: 'scheduled',
            created_at: new Date().toISOString()
        };
        
        res.json({
            success: true,
            post: scheduledPost,
            message: `Post scheduled for ${platform}`
        });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/analytics/overview', (req, res) => {
    const sampleAnalytics = {
        social_media: {
            instagram: {
                followers: 1250,
                engagement_rate: 4.2,
                posts_this_week: 12,
                avg_likes_per_post: 89
            },
            facebook: {
                page_likes: 3400,
                reach: 12500,
                engagement: 340,
                posts_this_week: 8
            },
            twitter: {
                followers: 2100,
                tweets_this_week: 24,
                avg_retweets: 15,
                engagement_rate: 2.8
            },
            linkedin: {
                connections: 850,
                posts_this_week: 6,
                engagement: 120,
                profile_views: 45
            }
        },
        content_performance: {
            total_posts: 50,
            total_engagement: 2340,
            avg_engagement_rate: 3.5,
            best_performing_post: {
                platform: 'instagram',
                engagement: 340,
                type: 'carousel'
            }
        },
        ai_generated_content: {
            total_generated: 125,
            avg_quality_score: 8.2,
            gpu_usage_hours: 24.5,
            cost_efficiency: 0.85
        }
    };
    
    res.json(sampleAnalytics);
});

app.get('/api/evolution/status', (req, res) => {
    res.json({
        self_evolution_enabled: true,
        last_evolution: new Date(Date.now() - 6 * 60 * 60 * 1000).toISOString(),
        evolution_count: 47,
        skills_synthesized: 12,
        performance_improvement: 23.4,
        current_focus: 'instagram_hashtag_optimization'
    });
});

// Error handling
app.use((err, req, res, next) => {
    logger.error(err.stack);
    res.status(500).json({ error: 'Something went wrong!' });
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({ error: 'Endpoint not found' });
});

// Start server
const server = app.listen(PORT, () => {
    logger.info(`🚀 MAYA Orchestrator running on port ${PORT}`);
    logger.info('✅ Ready for social media automation!');
});

module.exports = app;