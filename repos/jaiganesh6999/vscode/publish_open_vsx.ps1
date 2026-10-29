<#
.SYNOPSIS
    SEOWebChecker - Open VSX Registry Publishing Script
.DESCRIPTION
    Automates publishing the SEOWebChecker VS Code extension (.vsix) to Open VSX (open-vsx.org).
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Token = ""
)

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  SEOWebChecker: Open VSX (open-vsx.org) Publisher" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host ""

$VsixPath = Join-Path $PSScriptRoot "seowebchecker-1.0.0.vsix"

if (-not (Test-Path $VsixPath)) {
    Write-Host "Packaging extension..." -ForegroundColor Yellow
    Push-Location $PSScriptRoot
    npx @vscode/vsce package --no-dependencies
    Pop-Location
}

if (-not (Test-Path $VsixPath)) {
    Write-Host "Error: Could not find $VsixPath" -ForegroundColor Red
    exit 1
}

Write-Host "[1/3] Target VSIX: $VsixPath" -ForegroundColor Green

if ([string]::IsNullOrWhiteSpace($Token)) {
    Write-Host ""
    Write-Host "Please provide your Open VSX Personal Access Token (PAT)." -ForegroundColor Yellow
    Write-Host "You can generate one at: https://open-vsx.org/user-settings/tokens" -ForegroundColor Gray
    Write-Host ""
    $Token = Read-Host "Enter Open VSX Access Token"
}

if ([string]::IsNullOrWhiteSpace($Token)) {
    Write-Host "Error: Access token cannot be empty." -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternatively, you can manually upload the extension at:" -ForegroundColor Cyan
    Write-Host "  https://open-vsx.org/" -ForegroundColor Cyan
    exit 1
}

Write-Host ""
Write-Host "[2/3] Publishing to Open VSX..." -ForegroundColor Cyan

# Attempt to publish
$publishOutput = npx ovsx publish "$VsixPath" -p "$Token" 2>&1
$publishOutput | ForEach-Object { Write-Host $_ }

if ($LASTEXITCODE -ne 0 -and ($publishOutput -match "Unknown publisher|Namespace not found")) {
    $manifest = Get-Content (Join-Path $PSScriptRoot "package.json") -Raw | ConvertFrom-Json
    $publisher = $manifest.publisher

    Write-Host ""
    Write-Host "Namespace '$publisher' does not exist yet. Attempting to create it..." -ForegroundColor Yellow
    npx ovsx create-namespace $publisher -p "$Token"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Namespace '$publisher' created successfully! Retrying publish..." -ForegroundColor Green
        npx ovsx publish "$VsixPath" -p "$Token"
    }
}

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[3/3] Successfully published to Open VSX!" -ForegroundColor Green
    Write-Host "View your extension listing on https://open-vsx.org" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Publish failed with exit code $LASTEXITCODE." -ForegroundColor Red
    Write-Host "Tips:" -ForegroundColor Yellow
    Write-Host "1. Ensure your Open VSX namespace matches the 'publisher' field in package.json." -ForegroundColor Yellow
    Write-Host "2. Try creating the namespace manually: npx ovsx create-namespace <publisher> -p <token>" -ForegroundColor Yellow
}
