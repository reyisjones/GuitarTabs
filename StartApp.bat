@echo off
echo ====================================
echo  Starting Guitar Tabs Application
echo ====================================
echo.

:: Set working directory to the script location
cd /d "%~dp0"

:: Check for Python
python --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Python is not installed or not in the PATH.
    echo Please install Python and try again.
    goto :error
)

:: Check for Node.js or Bun
where bun >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    where npm >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Neither Bun nor npm is installed or in the PATH.
        echo Please install Bun or Node.js and try again.
        goto :error
    )
)

:: Start the backend
echo Starting the backend server...
cd /d "%~dp0backend"
call pip install -r requirements.txt
start "Guitar Tabs Backend" cmd /c "set FLASK_APP=app.py && set FLASK_ENV=development && set FLASK_DEBUG=1 && python -m flask run --host=0.0.0.0 --port=5000"

:: Wait for the backend to be ready
echo Waiting for the backend to start...
timeout /t 5 /nobreak > nul

:: Start the frontend
echo Starting the frontend server...
cd /d "%~dp0frontend"

where bun >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo Using Bun for frontend...
    call bun install
    start "Guitar Tabs Frontend" cmd /c "bun run dev"
) else (
    echo Using npm for frontend...
    call npm install
    start "Guitar Tabs Frontend" cmd /c "npm run dev"
)

:: Wait for the frontend to be ready
echo Waiting for the frontend to start...
timeout /t 10 /nobreak > nul

:: Launch browser
echo Opening Guitar Tabs application in your browser...
start http://localhost:5173

echo.
echo ====================================
echo  Guitar Tabs Application is running
echo ====================================
echo.
echo * Backend: http://localhost:5000
echo * Frontend: http://localhost:5173
echo.
echo Close this window to shut down both servers.
echo.
pause
goto :cleanup

:error
echo.
echo Failed to start Guitar Tabs application.
pause
exit /b 1

:cleanup
echo.
echo Shutting down servers...
taskkill /FI "WINDOWTITLE eq Guitar Tabs Backend*" /F > nul 2>&1
taskkill /FI "WINDOWTITLE eq Guitar Tabs Frontend*" /F > nul 2>&1
echo Done!
exit /b 0
