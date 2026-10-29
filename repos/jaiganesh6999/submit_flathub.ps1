param(
    [string]$GitHubUser = "jaiganesh6999",
    [string]$AppId = "com.seowebchecker.seowebchecker"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sourceDir = Join-Path $scriptDir "flatpak"
$gitExe = "C:\Users\rinki\AppData\Local\GitHubDesktop\app-3.6.6\resources\app\git\cmd\git.exe"

$forkUrl = "https://github.com/$GitHubUser/flathub.git"
$tempDir = Join-Path $env:TEMP "flathub-submission"

Write-Host "Automated Flathub Submitter for $AppId" -ForegroundColor Cyan
Write-Host "Checking fork at $forkUrl..." -ForegroundColor Gray

# Check if fork exists on GitHub
$remoteExists = $false
try {
    $heads = & $gitExe ls-remote --heads $forkUrl 2>&1
    if ($LASTEXITCODE -eq 0 -and $heads) {
        $remoteExists = $true
    }
} catch {
    $remoteExists = $false
}

if (-not $remoteExists) {
    Write-Host "`n[STEP 1 REQUIRED] Fork the Flathub repository on GitHub:" -ForegroundColor Yellow
    Write-Host "  1. Open: https://github.com/flathub/flathub" -ForegroundColor White
    Write-Host "  2. Click 'Fork' (top right)" -ForegroundColor White
    Write-Host "  3. Re-run this script: .\submit_flathub.bat`n" -ForegroundColor Cyan
    exit 1
}

Write-Host "Fork detected! Cloning $forkUrl..." -ForegroundColor Green
if (Test-Path $tempDir) {
    Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
}

& $gitExe clone $forkUrl $tempDir
Set-Location $tempDir

# Add official upstream flathub repository and fetch new-pr branch
Write-Host "Fetching official Flathub 'new-pr' branch..." -ForegroundColor Cyan
& $gitExe remote add upstream "https://github.com/flathub/flathub.git"
& $gitExe fetch upstream new-pr

# Create branch from upstream/new-pr
$branchName = "add-$AppId"
& $gitExe checkout -b $branchName upstream/new-pr

# Copy all flatpak files into repo root
Write-Host "Copying Flatpak manifest, metainfo, desktop entry, and icon..." -ForegroundColor Cyan
Copy-Item (Join-Path $sourceDir "*") $tempDir -Force

& $gitExe add -A
& $gitExe commit -m "Add $AppId"

Write-Host "Pushing branch '$branchName' to your fork..." -ForegroundColor Cyan
& $gitExe push -u origin $branchName

Write-Host "`nBranch successfully pushed to GitHub!" -ForegroundColor Green
Write-Host "Click this direct link to open the Pull Request on Flathub:" -ForegroundColor Yellow
Write-Host "👉 https://github.com/flathub/flathub/compare/new-pr...$($GitHubUser):flathub:$branchName?expand=1`n" -ForegroundColor White

Set-Location $scriptDir
