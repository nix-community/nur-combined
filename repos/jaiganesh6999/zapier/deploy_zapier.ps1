<#
.SYNOPSIS
    SEOWebChecker - Zapier Platform Deployment Script
.DESCRIPTION
    Builds, tests, validates, and deploys the SEOWebChecker integration to Zapier.
#>

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  SEOWebChecker: Zapier Platform Deployment Tool" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

Push-Location $PSScriptRoot

Write-Host "[1/4] Running automated tests..." -ForegroundColor Yellow
npm test
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Unit tests failed." -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host ""
Write-Host "[2/4] Validating against Zapier standards..." -ForegroundColor Yellow
npx zapier-platform-cli validate
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Validation failed." -ForegroundColor Red
    Pop-Location
    exit 1
}

Write-Host ""
Write-Host "[3/4] Checking Zapier authentication..." -ForegroundColor Yellow
npx zapier-platform-cli whoami 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Not logged in to Zapier. Launching login..." -ForegroundColor Cyan
    npx zapier-platform-cli login
}

Write-Host ""
Write-Host "[4/4] Deploying to Zapier Cloud..." -ForegroundColor Cyan
npx zapier-platform-cli push

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Successfully deployed SEOWebChecker to Zapier!" -ForegroundColor Green
    Write-Host "Manage your integration at: https://developer.zapier.com/" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Deployment failed with exit code $LASTEXITCODE." -ForegroundColor Red
    Write-Host "If this is the first deployment, register your app first:" -ForegroundColor Yellow
    Write-Host "  npx zapier-platform-cli register 'SEOWebChecker'" -ForegroundColor Yellow
}

Pop-Location
