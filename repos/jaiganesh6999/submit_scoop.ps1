# Automated Scoop Submitter & Sync Script for SEOWebChecker
# Official Tool: https://seowebchecker.com/
# Package Manifest: scoop/bucket/seowebchecker.json

$ErrorActionPreference = "Stop"

Write-Host "=== SEOWebChecker Scoop Publisher ===" -ForegroundColor Cyan
Write-Host "Target: https://github.com/jaiganesh6999/scoop-bucket" -ForegroundColor Yellow

$git = "C:\Users\rinki\AppData\Local\GitHubDesktop\app-3.6.6\resources\app\git\cmd\git.exe"
if (-not (Test-Path $git)) {
    $git = "git"
}

$tempDir = Join-Path $env:TEMP "scoop-bucket-staging"
if (Test-Path $tempDir) {
    Remove-Item -Recurse -Force $tempDir
}

Write-Host "Cloning official scoop-bucket..." -ForegroundColor Yellow
& $git clone https://github.com/jaiganesh6999/scoop-bucket.git $tempDir

$bucketDir = Join-Path $tempDir "bucket"
if (-not (Test-Path $bucketDir)) {
    New-Item -ItemType Directory -Path $bucketDir -Force | Out-Null
}

Copy-Item "scoop\bucket\seowebchecker.json" -Destination (Join-Path $bucketDir "seowebchecker.json") -Force

Set-Location $tempDir
& $git add .
$status = & $git status --porcelain
if ($status) {
    & $git commit -m "update: sync seowebchecker manifest v1.0.1"
    & $git push origin main
    Write-Host "Successfully synced to jaiganesh6999/scoop-bucket!" -ForegroundColor Green
} else {
    Write-Host "Bucket is already up-to-date." -ForegroundColor Green
}

Set-Location $PSScriptRoot
Write-Host "`nScoop Bucket: https://github.com/jaiganesh6999/scoop-bucket" -ForegroundColor Cyan
Write-Host "Official Main PR: https://github.com/ScoopInstaller/Main/pull/8555" -ForegroundColor Cyan
