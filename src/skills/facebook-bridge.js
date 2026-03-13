:const puppeteer = require('puppeteer-extra');
const StealthPlugin = require('puppeteer-extra-plugin-stealth');
const winston = require('winston');

puppeteer.use(StealthPlugin());

class FacebookBridge {
    constructor(config) {
        this.config = config;
        this.browser = null;
        this.page = null;
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
            args: ['--no-sandbox', '--disable-setuid-sandbox'],
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

    async close() {
        this.logger.info('Closing Facebook Bridge...');
        
        if (this.browser) {
            await this.browser.close();
        }
        
        this.logger.info('Facebook Bridge closed');
    }
}

module.exports = FacebookBridge;