# Troubleshooting the Start-App Scripts

This guide provides detailed steps to fix common issues with the Guitar Tabs application startup scripts.

## Quick Fixes

### If the Backend Server Fails to Start

1. **Check Python Installation**:
   ```powershell
   python --version
   ```

2. **Manually Install Requirements**:
   ```powershell
   cd backend
   pip install -r requirements.txt
   ```

3. **Manually Start Flask**:
   ```powershell
   cd backend
   $env:FLASK_APP = "app.py"
   $env:FLASK_DEBUG = "1"
   python -m flask run --host=0.0.0.0 --port=5000
   ```

4. **Check if Port 5000 is Used**:
   ```powershell
   netstat -ano | findstr :5000
   ```

### If the Frontend Server Fails to Start

1. **Check Bun/NPM Installation**:
   ```powershell
   bun --version
   # or
   npm --version
   ```

2. **Manually Install Dependencies**:
   ```powershell
   cd frontend
   bun install
   # or
   npm install
   ```

3. **Manually Start Vite Dev Server**:
   ```powershell
   cd frontend
   bun run dev
   # or
   npm run dev
   ```

## Detailed Solutions

### Python Errors

If you see errors like:

```
'python' is not recognized as an internal or external command
```

**Fix**: Download and install Python from [python.org](https://www.python.org/downloads/) and make sure to check "Add Python to PATH" during installation.

### Flask Errors

If you see errors like:

```
Error: Could not locate a Flask application...
```

**Fix**: Make sure you're in the correct directory and try:

```powershell
cd backend
$env:FLASK_APP = "app.py"
$env:PYTHONPATH = $PWD
python -m flask run
```

If you see errors about Flask decorators like:

```
AttributeError: 'Flask' object has no attribute 'before_first_request'
```

**Fix**: This happens with Flask 2.0+ where the `before_first_request` decorator was removed. Try cleaning up Python bytecode cache and making sure your code uses the app context pattern:

```powershell
# Remove Python bytecode cache
cd backend
if (Test-Path "__pycache__") {
    Remove-Item "__pycache__" -Recurse -Force
}

# Make sure app.py uses the modern pattern:
# with app.app_context():
#     create_test_user()  # instead of @app.before_first_request
```

### Bun/NPM Errors

If you see errors like:

```
'bun' is not recognized as an internal or external command
```

**Fix**:
- For Bun: Install Bun using `curl -fsSL https://bun.sh/install | bash` (macOS/Linux) or `powershell -c "irm bun.sh/install.ps1 | iex"` (Windows)
- For NPM: Install Node.js from [nodejs.org](https://nodejs.org/)

### Port Conflicts

If you see errors like:

```
Address already in use
```

**Fix**: Find and terminate the process using the port:

```powershell
# Find process using port 5000
netstat -ano | findstr :5000

# Kill the process (replace PID with the process ID)
taskkill /F /PID PID
```

### CORS Issues

If you see errors in the browser console about CORS:

**Fix**: Ensure your backend app.py has:

```python
from flask_cors import CORS
app = Flask(__name__)
CORS(app)
```

## Using Different Ports

If port 5000 or 5173 is consistently being used by another application:

1. Modify the start-app.ps1 script:
   ```powershell
   $backendUrl = "http://localhost:8000"  # Changed from 5000
   ```

2. Change the Flask run command:
   ```powershell
   python -m flask run --host=0.0.0.0 --port=8000  # Changed from 5000
   ```

3. Update the .env file in frontend to point to the new backend URL.

## Manual Start Process

If the scripts continue to fail, you can start the application manually:

1. **Start Backend**:
   ```powershell
   cd backend
   pip install -r requirements.txt
   $env:FLASK_APP = "app.py"
   $env:FLASK_DEBUG = "1"
   python -m flask run --host=0.0.0.0 --port=5000
   ```

2. **In a new terminal, start Frontend**:
   ```powershell
   cd frontend
   bun install  # or npm install
   bun run dev  # or npm run dev
   ```

3. **Open in Browser**:
   Navigate to http://localhost:5173

## Tab Player Issues

### If the Tab Player Fails to Load or Gives Font Errors

If you see errors like:
```
[AlphaTab][Font] [alphaTab] Loading Failed, rendering cannot start NetworkError: A network error occurred.
[AlphaTab][Font] [alphaTab] Loading Failed, rendering cannot start Font not available
```

**Fix**:

1. **Copy AlphaTab Resources Manually**:
   ```powershell
   cd frontend
   npm run copy-resources
   # or
   bun run copy-resources
   ```

2. **Ensure Internet Connectivity**:
   The tab player may need to download resources from the internet on first load.

3. **Clear Browser Cache**:
   Sometimes font loading issues are related to cached resources.

4. **Check Console for Specific Errors**:
   Look for network errors or 404s related to font or soundfont files.

5. **Restart the Application**:
   After copying resources, restart both frontend and backend.
   
### If the Tab Player Shows Errors About Missing Properties

If you see errors like:
```
TypeError: Cannot read properties of undefined (reading 'on')
```

**Fix**:

1. **Check AlphaTab Version Compatibility**:
   ```powershell
   cd frontend
   npm list @coderline/alphatab
   ```

2. **Reinstall AlphaTab**:
   ```powershell
   cd frontend
   npm uninstall @coderline/alphatab
   npm install @coderline/alphatab@1.6.0
   ```

3. **Rebuild the Application**:
   ```powershell
   cd frontend
   npm run build
   npm run preview
   ```

## Docker Issues

### If Docker Build Fails with "System Cannot Find File Specified"

If you see errors like:
```
error during connect: Post "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/v1.49/build...
open //./pipe/dockerDesktopLinuxEngine: The system cannot find the file specified.
```

**Fix**:

1. **Start Docker Desktop**:
   - Launch Docker Desktop from the Start menu
   - Wait for Docker to fully start (the Docker icon in the system tray should be solid)
   - You should see "Docker Desktop is running" when you hover over the icon

2. **Verify Docker is Running**:
   ```powershell
   docker --version
   docker ps
   ```

3. **If Docker Desktop is not installed**:
   - Download from https://www.docker.com/products/docker-desktop/
   - Install and restart your computer
   - Enable WSL 2 integration if prompted

### If Docker Container Fails with "eventlet worker requires eventlet"

If you see errors like:
```
RuntimeError: eventlet worker requires eventlet 0.24.1 or higher
```

**Fix**: The requirements.txt has been updated to include eventlet. Rebuild the Docker image:

```powershell
cd backend
docker build -t guitar-tabs-backend .
docker run -p 5000:5000 guitar-tabs-backend
```

### Alternative: Run Without Docker

If Docker continues to have issues, you can run the backend directly:

```powershell
cd backend
pip install -r requirements.txt
python app.py
```
