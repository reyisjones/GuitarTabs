Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# Function to show GUI with progress
function Show-StartupProgress {
    param (
        [string]$StatusText,
        [int]$ProgressValue
    )
    
    if ($null -eq $script:Window) {
        # Create the Window
        $script:Window = New-Object System.Windows.Window
        $script:Window.Title = "Guitar Tabs - Starting Application"
        $script:Window.Width = 500
        $script:Window.Height = 250
        $script:Window.WindowStartupLocation = "CenterScreen"
        $script:Window.ResizeMode = "NoResize"
        $script:Window.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create(
            [System.IO.Path]::Combine($PSScriptRoot, "frontend", "public", "favicon.ico"))
        
        # Create a Grid layout
        $Grid = New-Object System.Windows.Controls.Grid
        $script:Window.Content = $Grid
        
        # Create rows for the grid
        $row1 = New-Object System.Windows.Controls.RowDefinition
        $row1.Height = New-Object System.Windows.GridLength(60)
        $row2 = New-Object System.Windows.Controls.RowDefinition
        $row2.Height = New-Object System.Windows.GridLength(30)
        $row3 = New-Object System.Windows.Controls.RowDefinition
        $row3.Height = New-Object System.Windows.GridLength(40)
        $row4 = New-Object System.Windows.Controls.RowDefinition
        $row4.Height = New-Object System.Windows.GridLength(40)
        $Grid.RowDefinitions.Add($row1)
        $Grid.RowDefinitions.Add($row2)
        $Grid.RowDefinitions.Add($row3)
        $Grid.RowDefinitions.Add($row4)
        
        # Add the title
        $Title = New-Object System.Windows.Controls.TextBlock
        $Title.Text = "Starting Guitar Tabs Application..."
        $Title.FontSize = 20
        $Title.HorizontalAlignment = "Center"
        $Title.VerticalAlignment = "Center"
        $Title.FontWeight = "Bold"
        $Grid.Children.Add($Title)
        [System.Windows.Controls.Grid]::SetRow($Title, 0)
        
        # Add the status text
        $script:StatusBlock = New-Object System.Windows.Controls.TextBlock
        $script:StatusBlock.Text = $StatusText
        $script:StatusBlock.FontSize = 14
        $script:StatusBlock.HorizontalAlignment = "Center"
        $script:StatusBlock.VerticalAlignment = "Center"
        $Grid.Children.Add($script:StatusBlock)
        [System.Windows.Controls.Grid]::SetRow($script:StatusBlock, 1)
        
        # Add the progress bar
        $script:ProgressBar = New-Object System.Windows.Controls.ProgressBar
        $script:ProgressBar.Height = 20
        $script:ProgressBar.Width = 400
        $script:ProgressBar.Minimum = 0
        $script:ProgressBar.Maximum = 100
        $script:ProgressBar.Value = $ProgressValue
        $Grid.Children.Add($script:ProgressBar)
        [System.Windows.Controls.Grid]::SetRow($script:ProgressBar, 2)
        
        # Add the cancel button
        $CancelButton = New-Object System.Windows.Controls.Button
        $CancelButton.Content = "Cancel"
        $CancelButton.Width = 100
        $CancelButton.Height = 30
        $CancelButton.Add_Click({
            $script:Cancelled = $true
            $script:Window.Close()
        })
        $Grid.Children.Add($CancelButton)
        [System.Windows.Controls.Grid]::SetRow($CancelButton, 3)
        
        # Show the window without blocking
        $script:Cancelled = $false
        $script:Window.Show()
    }
    else {
        # Update existing window
        $script:StatusBlock.Text = $StatusText
        $script:ProgressBar.Value = $ProgressValue
    }
}

# Close the window
function Close-StartupWindow {
    if ($null -ne $script:Window) {
        $script:Window.Close()
        $script:Window = $null
    }
}

# Configuration
$backendUrl = "http://localhost:5000"
$frontendUrl = "http://localhost:5173"
$maxRetries = 30
$retryDelay = 2

# Function to clean up processes when script exits
function Cleanup {
    # Kill any running Python processes started by this script
    Get-Process python -ErrorAction SilentlyContinue | Where-Object {
        $_.StartInfo.Environment["SCRIPT_PARENT"] -eq $PID
    } | Stop-Process -Force -ErrorAction SilentlyContinue
    
    # Kill any running Bun processes started by this script
    Get-Process bun -ErrorAction SilentlyContinue | Where-Object {
        $_.StartInfo.Environment["SCRIPT_PARENT"] -eq $PID
    } | Stop-Process -Force -ErrorAction SilentlyContinue
    
    Close-StartupWindow
}

# Navigate to script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -Path $scriptPath

# Start the startup UI
Show-StartupProgress -StatusText "Starting backend server..." -ProgressValue 10

try {
    # Set environment variables
    $env:PYTHONPATH = ".\backend"
    $env:FLASK_APP = "backend/app.py"
    $env:FLASK_ENV = "development"
    
    # Start the backend server
    Start-Process -FilePath "python" -ArgumentList "-m flask run --host=0.0.0.0 --port=5000" -WorkingDirectory ".\backend" -NoNewWindow
    
    # Wait for the backend server to be ready
    Show-StartupProgress -StatusText "Waiting for backend server to be ready..." -ProgressValue 30
    $isReady = $false
    $retryCount = 0
    
    while (-not $isReady -and $retryCount -lt $maxRetries -and -not $script:Cancelled) {
        $retryCount++
        try {
            $response = Invoke-WebRequest -Uri "$backendUrl/api/health" -Method Get -TimeoutSec 2 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                $isReady = $true
                Show-StartupProgress -StatusText "Backend server is ready!" -ProgressValue 50
            } else {
                $progressValue = 30 + ($retryCount / $maxRetries * 20)
                Show-StartupProgress -StatusText "Waiting for backend server... (Attempt $retryCount of $maxRetries)" -ProgressValue $progressValue
                Start-Sleep -Seconds $retryDelay
            }
        } catch {
            $progressValue = 30 + ($retryCount / $maxRetries * 20)
            Show-StartupProgress -StatusText "Waiting for backend server... (Attempt $retryCount of $maxRetries)" -ProgressValue $progressValue
            Start-Sleep -Seconds $retryDelay
        }
    }
    
    if ($script:Cancelled) {
        Cleanup
        exit
    }
    
    if (-not $isReady) {
        [System.Windows.MessageBox]::Show(
            "Backend server failed to start after $($maxRetries * $retryDelay) seconds.", 
            "Guitar Tabs - Error", 
            [System.Windows.MessageBoxButton]::OK, 
            [System.Windows.MessageBoxImage]::Error)
        Cleanup
        exit
    }
    
    # Start the frontend development server
    Show-StartupProgress -StatusText "Starting frontend server..." -ProgressValue 60
    Set-Location -Path ".\frontend"
    Start-Process -FilePath "bun" -ArgumentList "run dev" -WorkingDirectory ".\frontend" -NoNewWindow
    
    # Wait for the frontend server to be ready
    Show-StartupProgress -StatusText "Waiting for frontend server to be ready..." -ProgressValue 70
    $isReady = $false
    $retryCount = 0
    
    while (-not $isReady -and $retryCount -lt $maxRetries -and -not $script:Cancelled) {
        $retryCount++
        try {
            $response = Invoke-WebRequest -Uri $frontendUrl -Method Get -TimeoutSec 2 -ErrorAction SilentlyContinue
            if ($response.StatusCode -eq 200) {
                $isReady = $true
                Show-StartupProgress -StatusText "Frontend server is ready!" -ProgressValue 90
            } else {
                $progressValue = 70 + ($retryCount / $maxRetries * 20)
                Show-StartupProgress -StatusText "Waiting for frontend server... (Attempt $retryCount of $maxRetries)" -ProgressValue $progressValue
                Start-Sleep -Seconds $retryDelay
            }
        } catch {
            $progressValue = 70 + ($retryCount / $maxRetries * 20)
            Show-StartupProgress -StatusText "Waiting for frontend server... (Attempt $retryCount of $maxRetries)" -ProgressValue $progressValue
            Start-Sleep -Seconds $retryDelay
        }
    }
    
    if ($script:Cancelled) {
        Cleanup
        exit
    }
    
    if (-not $isReady) {
        [System.Windows.MessageBox]::Show(
            "Frontend server failed to start after $($maxRetries * $retryDelay) seconds.", 
            "Guitar Tabs - Error", 
            [System.Windows.MessageBoxButton]::OK, 
            [System.Windows.MessageBoxImage]::Error)
        Cleanup
        exit
    }
    
    # Open the application in the default web browser
    Show-StartupProgress -StatusText "Opening Guitar Tabs application in your browser..." -ProgressValue 100
    Start-Process $frontendUrl
    
    # Close the startup window
    Close-StartupWindow
    
    # Show success message
    [System.Windows.MessageBox]::Show(
        "Guitar Tabs application is now running!`n`nBackend: $backendUrl`nFrontend: $frontendUrl`n`nClose this dialog to keep the application running in the background.",
        "Guitar Tabs - Started Successfully",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Information)
    
    # Create a system tray icon
    $notifyIcon = New-Object System.Windows.Forms.NotifyIcon
    $notifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon([System.IO.Path]::Combine($PSScriptRoot, "frontend", "public", "favicon.ico"))
    $notifyIcon.Text = "Guitar Tabs Application"
    $notifyIcon.Visible = $true
    
    # Create context menu for the tray icon
    $contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
    
    # Add menu item to open app
    $openItem = $contextMenu.Items.Add("Open Guitar Tabs")
    $openItem.add_Click({
        Start-Process $frontendUrl
    })
    
    # Add menu item to exit
    $exitItem = $contextMenu.Items.Add("Exit")
    $exitItem.add_Click({
        $notifyIcon.Visible = $false
        Cleanup
        [System.Windows.Forms.Application]::Exit()
    })
    
    $notifyIcon.ContextMenuStrip = $contextMenu
    
    # Double-click opens the app
    $notifyIcon.add_Click({
        if ($_.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
            Start-Process $frontendUrl
        }
    })
    
    # Keep the application running
    $appContext = New-Object System.Windows.Forms.ApplicationContext
    [System.Windows.Forms.Application]::Run($appContext)
} catch {
    [System.Windows.MessageBox]::Show(
        "Error starting Guitar Tabs application: $_", 
        "Guitar Tabs - Error", 
        [System.Windows.MessageBoxButton]::OK, 
        [System.Windows.MessageBoxImage]::Error)
} finally {
    Cleanup
}
