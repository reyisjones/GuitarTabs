#!/bin/bash

# Guitar Tabs Application Startup Script
# This script starts both the backend and frontend servers in the correct order

# Define cleanup function to ensure processes are terminated on exit
cleanup() {
  echo -e "\n🛑 Cleaning up and stopping servers..."
  if [ -n "$backend_pid" ]; then
    kill $backend_pid 2>/dev/null
    echo "✅ Backend server stopped."
  fi
  if [ -n "$frontend_pid" ]; then
    kill $frontend_pid 2>/dev/null
    echo "✅ Frontend server stopped."
  fi
  echo "👋 Goodbye!"
  exit 0
}

# Set up trap to catch interrupts and exit signals
trap cleanup INT TERM EXIT

# Get script directory
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Set environment variables
cd "$SCRIPT_DIR"
export PYTHONPATH="$SCRIPT_DIR/backend"
export FLASK_APP="app.py"
export FLASK_ENV="development"
export FLASK_DEBUG=1

# Configuration
BACKEND_URL="http://localhost:5000"
FRONTEND_URL="http://localhost:5173"
MAX_RETRIES=30
RETRY_DELAY=2

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}🎸 Starting Guitar Tabs Application...${NC}"

# Function to clean up processes when script exits
cleanup() {
    echo -e "${YELLOW}🛑 Stopping servers...${NC}"
    
    # Kill backend process
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
    fi
    
    # Kill frontend process
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
    fi
    
    echo -e "${CYAN}👋 Goodbye!${NC}"
    exit
}

# Set up signal handling for cleanup
trap cleanup SIGINT SIGTERM EXIT

# Check for Python
if ! command -v python3 &> /dev/null; then
    if ! command -v python &> /dev/null; then
        echo -e "${RED}❌ Python is not installed or not in the PATH.${NC}"
        echo "Please install Python and try again."
        exit 1
    fi
    PYTHON_CMD="python"
else
    PYTHON_CMD="python3"
fi

# Check for Node.js or Bun
if ! command -v bun &> /dev/null; then
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}❌ Neither Bun nor npm is installed or in the PATH.${NC}"
        echo "Please install Bun or Node.js and try again."
        exit 1
    fi
    JS_CMD="npm"
    JS_RUN="npm run"
else
    JS_CMD="bun"
    JS_RUN="bun run"
fi

# Clean up cached Python bytecode
echo -e "${GREEN}🧹 Cleaning Python bytecode cache...${NC}"
cd "$SCRIPT_DIR/backend"
if [ -d "__pycache__" ]; then
    rm -rf __pycache__
    echo -e "${GREEN}✅ Python cache cleaned.${NC}"
else
    echo -e "${GREEN}✅ No Python cache to clean.${NC}"
fi

# Install backend dependencies
echo -e "${GREEN}📦 Installing backend dependencies...${NC}"
$PYTHON_CMD -m pip install -r requirements.txt

# Start the backend server
echo -e "${GREEN}🚀 Starting Flask backend server...${NC}"
$PYTHON_CMD -m flask run --host=0.0.0.0 --port=5000 &
backend_pid=$!
cd "$SCRIPT_DIR"

# Wait for the backend server to be ready
echo -e "${YELLOW}⏳ Waiting for backend server to be ready...${NC}"
IS_READY=false
RETRY_COUNT=0

while [ "$IS_READY" = false ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    RETRY_COUNT=$((RETRY_COUNT+1))
    
    # Try to connect to the backend health endpoint
    if curl -s -o /dev/null -w "%{http_code}" $BACKEND_URL/api/health | grep -q "200"; then
        IS_READY=true
        echo -e "${GREEN}✅ Backend server is ready!${NC}"
    else
        echo -e "${YELLOW}⏳ Waiting for backend server... (Attempt $RETRY_COUNT of $MAX_RETRIES)${NC}"
        sleep $RETRY_DELAY
    fi
done

if [ "$IS_READY" = false ]; then
    echo -e "${RED}❌ Backend server failed to start after $((MAX_RETRIES * RETRY_DELAY)) seconds.${NC}"
    cleanup
    exit 1
fi

# Start the frontend development server
echo -e "${GREEN}🚀 Starting frontend development server...${NC}"
cd "$SCRIPT_DIR/frontend"

# Install frontend dependencies
echo -e "${GREEN}📦 Installing frontend dependencies with $JS_CMD...${NC}"
$JS_CMD install

# Start frontend server
$JS_RUN dev &
frontend_pid=$!
cd "$SCRIPT_DIR"

# Wait for the frontend server to be ready
echo -e "${YELLOW}⏳ Waiting for frontend server to be ready...${NC}"
IS_READY=false
RETRY_COUNT=0

while [ "$IS_READY" = false ] && [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    RETRY_COUNT=$((RETRY_COUNT+1))
    
    # Try to connect to the frontend
    if curl -s -o /dev/null -w "%{http_code}" $FRONTEND_URL | grep -q "200"; then
        IS_READY=true
        echo -e "${GREEN}✅ Frontend server is ready!${NC}"
    else
        echo -e "${YELLOW}⏳ Waiting for frontend server... (Attempt $RETRY_COUNT of $MAX_RETRIES)${NC}"
        sleep $RETRY_DELAY
    fi
done

if [ "$IS_READY" = false ]; then
    echo -e "${RED}❌ Frontend server failed to start after $((MAX_RETRIES * RETRY_DELAY)) seconds.${NC}"
    cleanup
    exit 1
fi

# Open the application in the default web browser
echo -e "${CYAN}🌐 Opening Guitar Tabs application in your browser...${NC}"
if command -v xdg-open > /dev/null; then
    xdg-open $FRONTEND_URL # Linux
elif command -v open > /dev/null; then
    open $FRONTEND_URL # macOS
fi

echo -e "${CYAN}🎸 Guitar Tabs application is now running!${NC}"
echo -e "${CYAN}   Backend: $BACKEND_URL${NC}"
echo -e "${CYAN}   Frontend: $FRONTEND_URL${NC}"
echo -e "${YELLOW}   Press Ctrl+C to stop the servers.${NC}"

# Keep the script running until user presses Ctrl+C
wait
