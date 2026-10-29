param(
    [string]$Pat = $env:AZURE_DEVOPS_PAT,
    [string]$Org = "seowebchecker",
    [string]$Project = "seowebchecker-seoaudit-sdk",
    [string]$Feed = "seowebchecker"
)

$ErrorActionPreference = "Stop"

if (-not $Pat) {
    Write-Host "Please provide your Azure DevOps Personal Access Token (PAT) via -Pat parameter or AZURE_DEVOPS_PAT environment variable." -ForegroundColor Yellow
    Write-Host "Create a PAT with 'Packaging (Read, write, & manage)' permissions at: https://dev.azure.com/$Org/_usersSettings/tokens" -ForegroundColor Cyan
    exit 1
}

Write-Host "Target Azure Artifacts Feed: https://dev.azure.com/$Org/$Project/_artifacts/feed/$Feed" -ForegroundColor Green

# 1. Push NuGet Package
$nupkg = "dotnet/nupkg/SeoWebChecker.SeoAudit.1.0.0.nupkg"
if (Test-Path $nupkg) {
    $nugetFeedUrl = "https://pkgs.dev.azure.com/$Org/$Project/_packaging/$Feed/nuget/v3/index.json"
    Write-Host "Pushing NuGet package to Azure Artifacts..." -ForegroundColor Cyan
    dotnet nuget push $nupkg --source $nugetFeedUrl --api-key $Pat --skip-duplicate
}

# 2. Push Python Wheel
$wheel = "python/dist/seowebchecker_seoaudit_sdk-1.0.0-py3-none-any.whl"
if (Test-Path $wheel) {
    $pypiFeedUrl = "https://pkgs.dev.azure.com/$Org/$Project/_packaging/$Feed/pypi/upload/"
    Write-Host "Pushing Python Wheel to Azure Artifacts..." -ForegroundColor Cyan
    python -m twine upload --repository-url $pypiFeedUrl -u $Org -p $Pat $wheel --skip-existing
}

Write-Host "Azure Artifacts publishing process completed!" -ForegroundColor Green
Write-Host "Feed URL: https://dev.azure.com/$Org/$Project/_artifacts/feed/$Feed" -ForegroundColor Yellow
