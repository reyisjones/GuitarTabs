# Guitar Tabs Application - Startup Instructions

This document explains how to start the Guitar Tabs application using the provided startup scripts.

## Quick Start

### Windows Users

1. Double-click the `StartApp.bat` file to start both the backend and frontend servers.
2. Wait for the application to launch in your default web browser.
3. Press `Ctrl+C` in the terminal window to stop the servers when you're done.

### Linux/Mac Users

1. Make the script executable:
   ```bash
   chmod +x start-app.sh
   ```

2. Run the script:
   ```bash
   ./start-app.sh
   ```

3. Press `Ctrl+C` to stop the servers when you're done.

## Advanced Usage

### PowerShell Script (Windows)

For more control, you can directly run the PowerShell script:

```powershell
PowerShell -ExecutionPolicy Bypass -File "start-app.ps1"
```

### Creating an Executable (Windows)

To create a standalone executable that doesn't require a visible console window:

1. Install the PS2EXE module:
   ```powershell
   Install-Module -Name PS2EXE
   ```

2. Convert the GUI PowerShell script to an EXE:
   ```powershell
   Invoke-ps2exe -InputFile .\StartAppGUI.ps1 -OutputFile .\GuitarTabs.exe -IconFile .\frontend\public\favicon.ico -NoConsole -RequireAdmin
   ```

3. Double-click the resulting `GuitarTabs.exe` to run the application with a graphical user interface.

## Troubleshooting

### Backend Server Issues

- **Python Not Found**: Ensure Python is installed and in your PATH. Run `python --version` to verify.
- **Flask Not Found**: Run `pip install flask flask-cors flask-socketio python-dotenv werkzeug PyJWT flask-jwt-extended bcrypt` to install required packages.
- **Port Already in Use**: Check if port 5000 is already being used by another application. Try terminating other Python processes.
- **Environment Variables**: Make sure FLASK_APP is set correctly. In PowerShell, use `$env:FLASK_APP = "app.py"`.
- **Running Directly**: Try running the backend manually to see specific errors:
  ```bash
  cd backend
  python -m flask run --host=0.0.0.0 --port=5000
  ```

### Frontend Server Issues

- **Bun/Node.js Missing**: Ensure either Bun or Node.js is installed. Run `bun --version` or `npm --version` to verify.
- **Dependencies Not Installed**: Run `cd frontend && bun install` (or `npm install`) to install frontend dependencies.
- **Port Already in Use**: Check if port 5173 is already being used by another application.
- **Running Directly**: Try running the frontend manually:
  ```bash
  cd frontend
  bun run dev  # or npm run dev
  ```

### Connection Issues

- **CORS Errors**: Make sure the backend is properly configured to allow cross-origin requests.
- **API URL**: Verify the `.env` file in the frontend directory has the correct API URL:
  ```
  VITE_API_URL=http://localhost:5000
  ```

### Authentication Issues

- **Test User Credentials**: The application automatically creates a test user:
  - Username: `testuser`
  - Password: `[check development docs for password]`
  
- **JWT Token Issues**: If you're getting authentication errors:
  1. Try clearing your browser's local storage
  2. Restart both backend and frontend servers
  3. Check the browser console for specific error messages
  
- **Login Fails Silently**: If login appears to work but you're not redirected:
  1. Check the browser console for errors
  2. Verify the backend is running and accessible
  3. Make sure the JWT token is being saved correctly in local storage

### Cannot Create EXE File

- Ensure you have PowerShell 5.1 or higher installed
- Try running PowerShell as Administrator when installing PS2EXE
- Try using an alternative like NSIS to create a proper installer

## Manual Startup

If the scripts don't work for you, you can manually start the servers:

1. Start the backend server:
   ```bash
   cd backend
   python -m flask run --host=0.0.0.0 --port=5000
   ```

2. Start the frontend server (in a separate terminal):
   ```bash
   cd frontend
   bun run dev
   ```

3. Open your browser and navigate to http://localhost:5173
