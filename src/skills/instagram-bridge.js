:const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
const winston = require('winston');

puppeteer.use(StealthPlugin());

class InstagramBridge {
    constructor(config) {
        this.config = config;
        this.browser = null;
        this.page = null;
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
            args: ['--no-sandbox', '--disable-setuid-sandbox'],
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
            
            this.logger.info('Instagram login successful');
            return true;
            
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

            // Upload media if provided
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

    async close() {
        this.logger.info('Closing Instagram Bridge...');
        
        if (this.browser) {
            await this.browser.close();
        }
        
        this.logger.info('Instagram Bridge closed');
    }
}

module.exports = InstagramBridge;