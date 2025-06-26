#!/usr/bin/env powershell

<#
.SYNOPSIS
    Docker Helper Script for Guitar Tabs Frontend

.DESCRIPTION
    This script helps manage Docker operations for the Guitar Tabs frontend application.

.PARAMETER Action
    The action to perform: build, run, stop, logs, shell, clean, status

.EXAMPLE
    .\docker-helper.ps1 build
    Builds the Docker image

.EXAMPLE
    .\docker-helper.ps1 run
    Runs the Docker container

.EXAMPLE
    .\docker-helper.ps1 status
    Shows the current status of image and container
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("build", "run", "stop", "logs", "shell", "clean", "status")]
    [string]$Action
)

# Set error action preference
$ErrorActionPreference = "Stop"

$ImageName = "guitar-tabs-frontend"
$ContainerName = "guitar-tabs-frontend-container"

function Test-DockerRunning {
    try {
        $null = docker version 2>$null
        return $true
    } catch {
        Write-Host "❌ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
        Write-Host "   1. Open Docker Desktop" -ForegroundColor Yellow
        Write-Host "   2. Wait for it to fully start" -ForegroundColor Yellow
        Write-Host "   3. Try this command again" -ForegroundColor Yellow
        return $false
    }
}

function ShowStatus {
    Write-Host "📊 Docker Status:" -ForegroundColor Cyan
    
    # Check if image exists
    $imageExists = docker images --format "table {{.Repository}}" | Select-String -Pattern "^$ImageName$" -Quiet
    if ($imageExists) {
        Write-Host "   ✅ Image '$ImageName' exists" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Image '$ImageName' not found" -ForegroundColor Red
    }
    
    # Check if container is running
    $containerRunning = docker ps --format "table {{.Names}}" | Select-String -Pattern "^$ContainerName$" -Quiet
    if ($containerRunning) {
        Write-Host "   ✅ Container '$ContainerName' is running" -ForegroundColor Green
        Write-Host "   🌐 Frontend available at: http://localhost:8080" -ForegroundColor Cyan
    } else {
        $containerExists = docker ps -a --format "table {{.Names}}" | Select-String -Pattern "^$ContainerName$" -Quiet
        if ($containerExists) {
            Write-Host "   ⚠️  Container '$ContainerName' exists but is not running" -ForegroundColor Yellow
        } else {
            Write-Host "   ❌ Container '$ContainerName' not found" -ForegroundColor Red
        }
    }
}

function BuildImage {
    Write-Host "🔨 Building Docker image..." -ForegroundColor Cyan
    docker build -t $ImageName .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Image built successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ Build failed!" -ForegroundColor Red
        exit 1
    }
}

function RunContainer {
    # Stop existing container if running
    docker stop $ContainerName 2>$null
    docker rm $ContainerName 2>$null
    
    Write-Host "🚀 Starting container..." -ForegroundColor Cyan
    
    docker run -d --name $ContainerName -p 8080:80 $ImageName
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Container started successfully!" -ForegroundColor Green
        Write-Host "   Frontend available at: http://localhost:8080" -ForegroundColor Cyan
        Write-Host "   Note: Make sure backend is running on port 5000" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Failed to start container!" -ForegroundColor Red
        exit 1
    }
}

function StopContainer {
    Write-Host "🛑 Stopping container..." -ForegroundColor Yellow
    docker stop $ContainerName 2>$null
    docker rm $ContainerName 2>$null
    Write-Host "✅ Container stopped and removed." -ForegroundColor Green
}

function ShowLogs {
    Write-Host "📋 Container logs:" -ForegroundColor Cyan
    docker logs -f $ContainerName
}

function OpenShell {
    Write-Host "🐚 Opening shell in container..." -ForegroundColor Cyan
    docker exec -it $ContainerName /bin/sh
}

function CleanDocker {
    Write-Host "🧹 Cleaning up Docker resources..." -ForegroundColor Yellow
    docker stop $ContainerName 2>$null
    docker rm $ContainerName 2>$null
    docker rmi $ImageName 2>$null
    docker system prune -f
    Write-Host "✅ Cleanup complete!" -ForegroundColor Green
}

# Main script logic
try {
    if (-not (Test-DockerRunning)) {
        exit 1
    }

    switch ($Action) {
        "build" { BuildImage }
        "run" { RunContainer }
        "stop" { StopContainer }
        "logs" { ShowLogs }
        "shell" { OpenShell }
        "clean" { CleanDocker }
        "status" { ShowStatus }
    }
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
    exit 1
}
