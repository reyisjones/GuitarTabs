@echo off
echo ==================================================
echo     GUITAR TABS APPLICATION - SIMPLE STARTER
echo ==================================================
echo.
echo This script will start the Guitar Tabs application.
echo.

:: Set working directory to the script location
cd /d "%~dp0"

echo Checking dependencies...
echo.

:: Check for Python
echo Checking for Python...
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Python is not installed or not in the PATH.
    echo Please install Python from https://www.python.org/downloads/
    echo Be sure to check "Add Python to PATH" during installation.
    goto :error
) else (
    echo [OK] Python is installed.
)

:: Check for Node.js and npm
echo Checking for Node.js...
where node >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Node.js is not installed or not in the PATH.
    echo Please install Node.js from https://nodejs.org/
    goto :error
) else (
    echo [OK] Node.js is installed.
)

echo Checking for npm...
where npm >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] npm is not installed or not in the PATH.
    echo This is unusual as npm should be installed with Node.js.
    echo Please reinstall Node.js from https://nodejs.org/
    goto :error
) else (
    echo [OK] npm is installed.
)

echo All required dependencies are installed.
echo.

echo ==================================================
echo     STARTING BACKEND SERVER
echo ==================================================
echo.
cd /d "%~dp0backend"

:: Clean up any cached Python files
echo Cleaning up cached Python files...
if exist "__pycache__" (
    rd /s /q "__pycache__"
    echo [OK] Cleaned Python cache.
) else (
    echo [OK] No Python cache to clean.
)

:: Install Python dependencies
echo Installing Python dependencies...
pip install -r requirements.txt
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to install Python dependencies.
    goto :error
) else (
    echo [OK] Python dependencies installed.
)
echo.

:: Start the backend server in a new window
echo Starting Flask backend server on http://localhost:5000
start "Guitar Tabs Backend" cmd /c "set FLASK_APP=app.py && set FLASK_ENV=development && set FLASK_DEBUG=1 && python -m flask run --host=0.0.0.0 --port=5000"
echo [OK] Backend server started in a new window.

echo Waiting for the backend server to initialize...
timeout /t 5 /nobreak > nul

echo.
echo ==================================================
echo     STARTING FRONTEND SERVER
echo ==================================================
echo.
cd /d "%~dp0frontend"

:: Install Node.js dependencies
echo Installing frontend dependencies...
call npm install
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to install frontend dependencies.
    goto :error
) else (
    echo [OK] Frontend dependencies installed.
)
echo.

:: Start the frontend server in a new window
echo Starting Vite development server...
start "Guitar Tabs Frontend" cmd /c "npm run dev"
echo [OK] Frontend server started in a new window.

echo Waiting for the frontend server to initialize...
timeout /t 10 /nobreak > nul
echo.

:: Launch browser
echo Opening Guitar Tabs application in your browser...
start http://localhost:5173

echo.
echo ==================================================
echo     GUITAR TABS APPLICATION IS RUNNING
echo ==================================================
echo.
echo * Backend: http://localhost:5000
echo * Frontend: http://localhost:5173
echo.
echo TEST USER CREDENTIALS:
echo * Username: testuser
echo * Password: [check development docs for password]
echo.
echo The application is now running in separate windows.
echo DO NOT CLOSE THIS WINDOW while you want the application to run.
echo To stop the application, close this window and the server windows.
echo.
pause
goto :cleanup

:error
echo.
echo [ERROR] Failed to start Guitar Tabs application.
echo Please check the error messages above.
echo.
pause
exit /b 1

:cleanup
echo.
echo Shutting down servers...
taskkill /FI "WINDOWTITLE eq Guitar Tabs Backend*" /F > nul 2>&1
taskkill /FI "WINDOWTITLE eq Guitar Tabs Frontend*" /F > nul 2>&1
echo Done!
exit /b 0
