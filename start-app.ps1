# Guitar Tabs Application Startup Script
# This script starts both the backend and frontend servers in the correct order

# Set environment variables
$env:PYTHONPATH = "$PSScriptRoot\backend"
$env:FLASK_APP = "app.py"
$env:FLASK_ENV = "development"
$env:FLASK_DEBUG = "1"

# Configuration
$backendUrl = "http://localhost:5000"
$frontendUrl = "http://localhost:5173"
$maxRetries = 30
$retryDelay = 2

Write-Host "🎸 Starting Guitar Tabs Application..." -ForegroundColor Cyan

# Create a flag file to indicate if script was interrupted
$tempFile = [System.IO.Path]::GetTempFileName()

# Global process variables
$backendProcess = $null
$frontendProcess = $null

# Function to clean up processes when script exits
function Cleanup {
    Write-Host "🛑 Stopping servers..." -ForegroundColor Yellow
    
    # Stop backend process if it's running
    if ($null -ne $backendProcess -and -not $backendProcess.HasExited) {
        try {
            Stop-Process -Id $backendProcess.Id -Force -ErrorAction SilentlyContinue
            Write-Host "✅ Backend server stopped." -ForegroundColor Green
        } catch {
            Write-Host "⚠️ Could not stop backend server gracefully." -ForegroundColor Yellow
        }
    }
    
    # Stop frontend process if it's running
    if ($null -ne $frontendProcess -and -not $frontendProcess.HasExited) {
        try {
            Stop-Process -Id $frontendProcess.Id -Force -ErrorAction SilentlyContinue
            Write-Host "✅ Frontend server stopped." -ForegroundColor Green
        } catch {
            Write-Host "⚠️ Could not stop frontend server gracefully." -ForegroundColor Yellow
        }
    }
    
    # Additional cleanup for any stray processes
    $processes = @("python", "bun", "node")
    foreach ($proc in $processes) {
        Get-Process $proc -ErrorAction SilentlyContinue | Where-Object {
            $_.StartInfo.Environment["SCRIPT_PARENT"] -eq $PID
        } | Stop-Process -Force -ErrorAction SilentlyContinue
    }
    
    # Remove the temp file
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
    
    Write-Host "👋 Goodbye!" -ForegroundColor Cyan
}

# Register the cleanup function to run on script exit
try {
    # Register cleanup on script exit
    $null = Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action {
        Cleanup
    }
    
    # Also handle Ctrl+C
    [Console]::TreatControlCAsInput = $true
} catch {
    Write-Host "⚠️ Warning: Could not register cleanup handlers. Manual process cleanup may be required." -ForegroundColor Yellow
}

# Ensure the cleanup runs if the script is interrupted
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

try {    # Install required dependencies if necessary
    Write-Host "📦 Checking Python dependencies..." -ForegroundColor Cyan
    if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
        Write-Host "❌ pip not found! Please install Python properly." -ForegroundColor Red
        exit 1
    }
      # Clean up cached Python bytecode
    Write-Host "🧹 Cleaning Python bytecode cache..." -ForegroundColor Green
    if (Test-Path "$PSScriptRoot\backend\__pycache__") {
        Remove-Item "$PSScriptRoot\backend\__pycache__" -Recurse -Force
        Write-Host "✅ Python cache cleaned." -ForegroundColor Green
    }
    else {
        Write-Host "✅ No Python cache to clean." -ForegroundColor Green
    }

    # Install dependencies
    Write-Host "📦 Installing required Python packages..." -ForegroundColor Green
    Start-Process -FilePath "pip" -ArgumentList "install -r requirements.txt" -WorkingDirectory "$PSScriptRoot\backend" -Wait -NoNewWindow
    
    # Start the backend server
    Write-Host "🚀 Starting Flask backend server..." -ForegroundColor Green
    $backendProcess = Start-Process -FilePath "python" -ArgumentList "-m flask run --host=0.0.0.0 --port=5000" -WorkingDirectory "$PSScriptRoot\backend" -PassThru -NoNewWindow
    
    # Wait for the backend server to be ready
    Write-Host "⏳ Waiting for backend server to be ready..." -ForegroundColor Yellow
    $isReady = $false
    $retryCount = 0
    
    while (-not $isReady -and $retryCount -lt $maxRetries) {
        $retryCount++
        try {
            $response = Invoke-WebRequest -Uri "$backendUrl/api/health" -Method Get -TimeoutSec 2 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                $isReady = $true
                Write-Host "✅ Backend server is ready!" -ForegroundColor Green
            } else {
                Write-Host "⏳ Waiting for backend server... (Attempt $retryCount of $maxRetries)" -ForegroundColor Yellow
                Start-Sleep -Seconds $retryDelay
            }
        } catch {
            Write-Host "⏳ Waiting for backend server... (Attempt $retryCount of $maxRetries)" -ForegroundColor Yellow
            Start-Sleep -Seconds $retryDelay
        }
    }
    
    if (-not $isReady) {
        throw "Backend server failed to start after $($maxRetries * $retryDelay) seconds."
    }
      # Start the frontend development server
    Write-Host "🚀 Starting frontend development server..." -ForegroundColor Green
    
    # Check if bun is installed
    if (-not (Get-Command bun -ErrorAction SilentlyContinue)) {
        Write-Host "⚠️ Bun is not installed. Attempting to use npm instead..." -ForegroundColor Yellow
        
        # Check if Node.js/npm is installed
        if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
            Write-Host "❌ Neither Bun nor npm are installed! Please install Bun or Node.js." -ForegroundColor Red
            exit 1
        }
        
        # Install dependencies using npm
        Write-Host "📦 Installing frontend dependencies with npm..." -ForegroundColor Green
        Start-Process -FilePath "npm" -ArgumentList "install" -WorkingDirectory "$PSScriptRoot\frontend" -Wait -NoNewWindow
        
        # Start dev server with npm
        $frontendProcess = Start-Process -FilePath "npm" -ArgumentList "run dev" -WorkingDirectory "$PSScriptRoot\frontend" -PassThru -NoNewWindow
    } else {
        # Install dependencies using bun
        Write-Host "📦 Installing frontend dependencies with bun..." -ForegroundColor Green
        Start-Process -FilePath "bun" -ArgumentList "install" -WorkingDirectory "$PSScriptRoot\frontend" -Wait -NoNewWindow
        
        # Start dev server with bun
        $frontendProcess = Start-Process -FilePath "bun" -ArgumentList "run dev" -WorkingDirectory "$PSScriptRoot\frontend" -PassThru -NoNewWindow
    }
    
    # Wait for the frontend server to be ready
    Write-Host "⏳ Waiting for frontend server to be ready..." -ForegroundColor Yellow
    $isReady = $false
    $retryCount = 0
    
    while (-not $isReady -and $retryCount -lt $maxRetries) {
        $retryCount++
        try {
            $response = Invoke-WebRequest -Uri $frontendUrl -Method Get -TimeoutSec 2 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                $isReady = $true
                Write-Host "✅ Frontend server is ready!" -ForegroundColor Green
            } else {
                Write-Host "⏳ Waiting for frontend server... (Attempt $retryCount of $maxRetries)" -ForegroundColor Yellow
                Start-Sleep -Seconds $retryDelay
            }
        } catch {
            Write-Host "⏳ Waiting for frontend server... (Attempt $retryCount of $maxRetries)" -ForegroundColor Yellow
            Start-Sleep -Seconds $retryDelay
        }
    }
    
    if (-not $isReady) {
        throw "Frontend server failed to start after $($maxRetries * $retryDelay) seconds."
    }
    
    # Open the application in the default web browser
    Write-Host "🌐 Opening Guitar Tabs application in your browser..." -ForegroundColor Cyan
    Start-Process $frontendUrl
    
    Write-Host "🎸 Guitar Tabs application is now running!" -ForegroundColor Cyan
    Write-Host "   Backend: $backendUrl" -ForegroundColor Cyan
    Write-Host "   Frontend: $frontendUrl" -ForegroundColor Cyan
    Write-Host "   Press Ctrl+C to stop the servers." -ForegroundColor Yellow
    
    # Keep the script running until user presses Ctrl+C
    while ($true) {
        if ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)
            if ($key.Key -eq "C" -and $key.Modifiers -eq "Control") {
                Write-Host "Ctrl+C detected. Stopping servers..." -ForegroundColor Yellow
                break
            }
        }
        Start-Sleep -Milliseconds 100
    }
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    exit 1
} finally {
    Cleanup
}
