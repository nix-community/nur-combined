param(
    [string]$Token = $env:GITHUB_TOKEN,
    [string]$Owner = "jaiganesh6999"
)

$ErrorActionPreference = "Stop"

if (-not $Token) {
    Write-Host "Please provide your GitHub Personal Access Token (PAT) with 'write:packages' scope." -ForegroundColor Yellow
    Write-Host "Create a classic PAT at: https://github.com/settings/tokens/new?scopes=write:packages,read:packages" -ForegroundColor Cyan
    exit 1
}

# 1. Push NuGet to GitHub Packages
$nupkg = "dotnet/nupkg/SeoWebChecker.SeoAudit.1.0.0.nupkg"
if (Test-Path $nupkg) {
    Write-Host "Pushing NuGet package to GitHub Packages..." -ForegroundColor Cyan
    $sourceUrl = "https://nuget.pkg.github.com/$Owner/index.json"
    
    $sources = dotnet nuget list source
    if ($sources -notmatch "github-pkg") {
        dotnet nuget add source $sourceUrl --name "github-pkg" --username $Owner --password $Token --store-password-in-clear-text
    }
    dotnet nuget push $nupkg --source "github-pkg" --skip-duplicate --api-key $Token
    Write-Host "NuGet package pushed to GitHub Packages!" -ForegroundColor Green
}

Write-Host "View your public packages at: https://github.com/$Owner?tab=packages" -ForegroundColor Yellow
