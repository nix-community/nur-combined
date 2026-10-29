param(
    [string]$ApiKey = $env:CLOUDSMITH_API_KEY,
    [string]$Owner = "seowebchecker",
    [string]$Repo = "seowebchecker-seoaudit-sdk"
)

$ErrorActionPreference = "Stop"

$cloudsmithExe = "C:\Users\rinki\AppData\Roaming\Python\Python314\Scripts\cloudsmith.exe"
if (-not (Test-Path $cloudsmithExe)) {
    $cloudsmithCmd = Get-Command cloudsmith -ErrorAction SilentlyContinue
    if ($cloudsmithCmd) {
        $cloudsmithExe = $cloudsmithCmd.Source
    } else {
        Write-Error "cloudsmith CLI not found. Run: pip install --upgrade cloudsmith-cli"
        exit 1
    }
}

if ($ApiKey) {
    $env:CLOUDSMITH_API_KEY = $ApiKey
}

if (-not $env:CLOUDSMITH_API_KEY) {
    Write-Host "Please provide your Cloudsmith API key via -ApiKey parameter or CLOUDSMITH_API_KEY environment variable." -ForegroundColor Yellow
    Write-Host "Get your API key at: https://cloudsmith.io/user/settings/api/" -ForegroundColor Cyan
    exit 1
}

Write-Host "Verifying Cloudsmith authentication..." -ForegroundColor Cyan
& $cloudsmithExe whoami

$targetRepo = "$Owner/$Repo"
Write-Host "Target Cloudsmith repository: $targetRepo" -ForegroundColor Green

# 1. Python Wheel
$wheel = "python/dist/seowebchecker_seoaudit_sdk-1.0.0-py3-none-any.whl"
if (Test-Path $wheel) {
    Write-Host "Pushing Python Wheel to Cloudsmith..." -ForegroundColor Cyan
    & $cloudsmithExe push python $targetRepo $wheel
}

# 2. NPM Package
$npmTgz = "npm/seowebchecker-seoaudit-sdk-1.0.1.tgz"
if (Test-Path $npmTgz) {
    Write-Host "Pushing NPM package to Cloudsmith..." -ForegroundColor Cyan
    & $cloudsmithExe push npm $targetRepo $npmTgz
}

# 3. NuGet Package
$nupkg = "dotnet/nupkg/SeoWebChecker.SeoAudit.1.0.0.nupkg"
if (Test-Path $nupkg) {
    Write-Host "Pushing NuGet package to Cloudsmith..." -ForegroundColor Cyan
    & $cloudsmithExe push nuget $targetRepo $nupkg
}

# 4. Ruby Gem
$gem = "ruby/seowebchecker-seoaudit-sdk-1.0.0.gem"
if (Test-Path $gem) {
    Write-Host "Pushing Ruby Gem to Cloudsmith..." -ForegroundColor Cyan
    & $cloudsmithExe push ruby $targetRepo $gem
}

# 5. Conda Package
$conda = "conda/dist/noarch/seowebchecker-seoaudit-sdk-1.0.0-py_0.tar.bz2"
if (Test-Path $conda) {
    Write-Host "Pushing Conda package to Cloudsmith..." -ForegroundColor Cyan
    & $cloudsmithExe push conda $targetRepo $conda
}

Write-Host "All packages processed for Cloudsmith ($targetRepo)!" -ForegroundColor Green
Write-Host "Live repository: https://cloudsmith.io/~$Owner/repos/$Repo/packages/" -ForegroundColor Yellow
