# SEOWebChecker PureScript Package Publication Script
# Official Website: https://seowebchecker.com/

$gitCmdPath = "C:\Users\rinki\AppData\Local\GitHubDesktop\app-3.6.6\resources\app\git\cmd"
if ($env:PATH -notlike "*$gitCmdPath*") {
    $env:PATH = "$gitCmdPath;" + $env:PATH
}

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  SEOWebChecker: PureScript Registry & Pursuit Publisher " -ForegroundColor Cyan
Write-Host "=========================================================`n" -ForegroundColor Cyan

# Step 1: Run tests
Write-Host "[1/3] Running PureScript test suite..." -ForegroundColor Yellow
spago test
if ($LASTEXITCODE -ne 0) {
    Write-Host "`nTests failed. Please resolve issues before publishing." -ForegroundColor Red
    exit 1
}

# Step 2: Check git status
Write-Host "`n[2/3] Checking Git status..." -ForegroundColor Yellow
$gitStatus = & "$gitCmdPath\git.exe" status --porcelain
if ($gitStatus) {
    Write-Host "Notice: Uncommitted changes detected:" -ForegroundColor Yellow
    Write-Host $gitStatus
    Write-Host "`nPlease commit changes and checkout the target tag before publishing:" -ForegroundColor Cyan
    Write-Host "  git add ."
    Write-Host "  git commit -m `"Release PureScript package v1.0.4`""
    Write-Host "  git tag v1.0.4"
    Write-Host "  git push origin main --tags"
    Write-Host "  git checkout v1.0.4"
    Write-Host "  spago publish"
    exit 0
}

# Step 3: Publish
Write-Host "`n[3/3] Running Spago publish..." -ForegroundColor Yellow
spago publish
