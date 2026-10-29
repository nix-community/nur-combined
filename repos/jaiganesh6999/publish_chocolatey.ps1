param(
    [string]$ApiKey = $env:CHOCOLATEY_API_KEY
)

$ErrorActionPreference = "Stop"

$chocoExe = "C:\ProgramData\chocolatey\bin\choco.exe"
if (-not (Test-Path $chocoExe)) {
    $chocoCmd = Get-Command choco -ErrorAction SilentlyContinue
    if ($chocoCmd) {
        $chocoExe = $chocoCmd.Source
    } else {
        Write-Error "choco CLI not found."
        exit 1
    }
}

if (-not $ApiKey) {
    Write-Host "Please provide your Chocolatey API Key via -ApiKey parameter or CHOCOLATEY_API_KEY environment variable." -ForegroundColor Yellow
    Write-Host "Get your API key at: https://community.chocolatey.org/account" -ForegroundColor Cyan
    exit 1
}

$nupkg = "chocolatey\seowebchecker.1.0.0.nupkg"
if (-not (Test-Path $nupkg)) {
    Write-Host "Packing Chocolatey package..." -ForegroundColor Cyan
    & $chocoExe pack chocolatey\seowebchecker.nuspec --outputdirectory chocolatey
}

Write-Host "Pushing package to Chocolatey Community Repository..." -ForegroundColor Cyan
& $chocoExe push $nupkg --source "'https://push.chocolatey.org/'" -k="'$ApiKey'"

Write-Host "Chocolatey package submitted successfully!" -ForegroundColor Green
Write-Host "Live URL (once moderation passes): https://community.chocolatey.org/packages/seowebchecker" -ForegroundColor Yellow
