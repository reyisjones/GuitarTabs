Write-Host "🔧 Fixing Storybook configuration..." -ForegroundColor Cyan

# Step 1: Clean up node_modules to avoid conflicts
Write-Host "Cleaning node_modules..." -ForegroundColor Yellow
if (Test-Path "node_modules") {
    Remove-Item -Recurse -Force "node_modules"
}

# Step 2: Clear npm cache
Write-Host "Clearing npm cache..." -ForegroundColor Yellow
npm cache clean --force

# Step 3: Reinstall dependencies
Write-Host "Reinstalling dependencies..." -ForegroundColor Green
npm install

# Step 4: Verify Storybook installation
Write-Host "Verifying Storybook installation..." -ForegroundColor Green
npx storybook --version

# Step 5: Build Storybook to check for errors
Write-Host "Building Storybook to verify configuration..." -ForegroundColor Green
npm run build-storybook

Write-Host "✅ Storybook configuration fixed successfully!" -ForegroundColor Cyan
Write-Host "You can now run 'npm run storybook' to start Storybook." -ForegroundColor Green
