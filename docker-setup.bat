@echo off
echo ================================================
echo     GUITAR TABS - DOCKER SETUP
echo ================================================
echo.

echo Checking Docker status...
docker --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Docker is not running or not installed.
    echo Please:
    echo 1. Install Docker Desktop from https://www.docker.com/products/docker-desktop/
    echo 2. Start Docker Desktop
    echo 3. Wait for it to fully start
    echo 4. Run this script again
    pause
    exit /b 1
) else (
    echo [OK] Docker is available.
)

echo.
echo Building backend Docker image...
cd /d "%~dp0backend"
docker build -t guitar-tabs-backend .
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to build backend image.
    pause
    exit /b 1
) else (
    echo [OK] Backend image built successfully.
)

echo.
echo Starting backend container...
docker stop guitar-tabs-backend-container >nul 2>&1
docker rm guitar-tabs-backend-container >nul 2>&1
docker run -d --name guitar-tabs-backend-container -p 5000:5000 -v "%cd%\uploads:/app/uploads" guitar-tabs-backend
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to start backend container.
    pause
    exit /b 1
) else (
    echo [OK] Backend container started successfully.
)

echo.
echo ================================================
echo     DOCKER SETUP COMPLETE
echo ================================================
echo.
echo * Backend: http://localhost:5000
echo * Health check: http://localhost:5000/api/health
echo.
echo To view logs: docker logs guitar-tabs-backend-container
echo To stop: docker stop guitar-tabs-backend-container
echo.
pause
