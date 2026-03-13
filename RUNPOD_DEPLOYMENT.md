# MAYA RunPod Deployment Guide

Based on the project structure, MAYA is a Self-Evolving Digital Marketing Agent featuring a Python backend (FastAPI in `src/main.py` or fallback `maya_server.py`), browser automation capabilities for social media, and AI content generation.

Since you are creating a **new custom Pod** on RunPod (which acts like a standard Ubuntu VPS with GPU access), here is the step-by-step guide on what files to move and how to run your backend.

## 📁 1. Files to Put in RunPod

You will need to transfer the core backend files to your new RunPod Pod. You can do this by either pushing your code to a private GitHub repository and cloning it inside the Pod, or by using SCP/SFTP to copy the files directly.

Transfer the following files and directories from your local `d:\MAYA` folder to the Pod (e.g., into `/workspace/MAYA`):

- `src/` (Contains your main FastAPI application `main.py`)
- `maya_server.py` (Fallback HTTP server)
- `config/` (Social media configurations, etc.)
- `skills/` (Social media browser bridge scripts)
- `requirements.txt` (Contains all Python dependencies; if it doesn't exist locally, you can extract it from the `deploy-runpod-final.sh` script)
- `start.sh` & `start-browser.sh` (Application and browser startup scripts)
- `.env` (Your environment variables containing API keys, Gmail credentials, etc.)

*(Note: Ignore folders like `node_modules`, `venv`, or `.git` when copying directly to save time and space).*

## 🚀 2. Setting Up the Pod

Once you have created your new Pod on RunPod and connected via SSH (e.g., `ssh root@<ip> -p <port>`), follow these steps to prepare the environment:

### A. Install System Dependencies
MAYA relies on Chrome headless for social media automation. Run these commands to install the necessary system packages:

```bash
apt-get update && apt-get install -y \
    python3-pip \
    python3-venv \
    curl \
    wget \
    xvfb \
    xauth \
    fonts-liberation \
    fonts-dejavu-core \
    fontconfig

# Install Google Chrome for browser automation
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
apt-get update
apt-get install -y google-chrome-stable
```

### B. Install Python Dependencies
Navigate to your project directory inside the Pod and install the required Python packages:

```bash
cd /workspace/MAYA

# It's recommended to use a virtual environment
python3 -m venv venv
source venv/bin/activate

# Install requirements
pip install -r requirements.txt
```

*(If you don't have `requirements.txt`, run `./deploy-runpod-final.sh` locally first to generate it, or copy the dependencies listed inside that script's source code).*

### C. Configure Environment Variables
Ensure your `.env` file is present in the project root with your valid keys:
```env
RUNPOD_API_KEY=your_key
GMAIL_USER=surya.girishad@gmail.com
GMAIL_PASS=your_app_password
# Add your OpenAI/Anthropic keys here for content generation
```

## 🏃 3. Starting the Backend

You can start the backend using the provided startup scripts which handle the virtual display (Xvfb) for Chrome and launch the FastAPI server.

```bash
# Make the scripts executable
chmod +x start.sh start-browser.sh

# Start the application
./start.sh
```

**What `start.sh` does:**
1. Starts a virtual display (`Xvfb`) on port `:99`.
2. Launches `start-browser.sh` which runs Chrome in headless debugging mode.
3. Launches the Python FastAPI server (`src/main.py`) on port `8000` (or `maya_server.py` on port `3000`).

## 🌐 4. Accessing Your Backend

Once started, your backend will be running inside the Pod.
- If your RunPod exposes HTTP ports automatically, you can access the API at the Pod's public proxy URL on the respective port (e.g., `8000` or `3000`).
- Check the health status by curling from within the Pod: `curl http://localhost:8000/health`
- API documentation will be available at `http://localhost:8000/docs`.

---
*Note: The repository also contains a `deploy-runpod-final.sh` script which attempts to use the RunPod Serverless API (`https://api.runpod.io/v2/endpoint`) to create an endpoint automatically. However, since you are manually spinning up a new GPU Pod and connecting via SSH/Jupyter, the manual setup steps above are the correct approach.*
