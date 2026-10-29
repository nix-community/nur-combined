param(
    [string]$ServerUrl = "https://seowebchecker.jfrog.io/artifactory",
    [string]$Token = $env:JFROG_ACCESS_TOKEN,
    [string]$Username = $env:JFROG_USER,
    [string]$Password = $env:JFROG_PASSWORD,
    [string]$Repo = "generic-local"
)

$ErrorActionPreference = "Stop"

if (-not $Token -and (-not $Username -or -not $Password)) {
    Write-Host "Please provide authentication for JFrog Artifactory:" -ForegroundColor Yellow
    Write-Host "  Option 1: -Token '<YOUR_ACCESS_TOKEN>' (or `$env:JFROG_ACCESS_TOKEN)" -ForegroundColor Cyan
    Write-Host "  Option 2: -Username '<USER>' -Password '<PASSWORD_OR_API_KEY>'" -ForegroundColor Cyan
    Write-Host "Generate an Access Token at: $ServerUrl (User Profile -> Access Tokens)" -ForegroundColor Gray
    exit 1
}

# Normalize ServerUrl (remove trailing slash if present)
$ServerUrl = $ServerUrl.TrimEnd('/')

# Setup auth header
if ($Token) {
    $authHeader = "Authorization: Bearer $Token"
} else {
    $authBytes = [System.Text.Encoding]::UTF8.GetBytes("${Username}:${Password}")
    $authBase64 = [System.Convert]::ToBase64String($authBytes)
    $authHeader = "Authorization: Basic $authBase64"
}

# Test connection
Write-Host "Testing connection to $ServerUrl..." -ForegroundColor Cyan
try {
    $ping = Invoke-WebRequest -Uri "$ServerUrl/api/system/ping" -UseBasicParsing
    if ($ping.StatusCode -eq 200) {
        Write-Host "Artifactory is online and reachable!" -ForegroundColor Green
    }
} catch {
    Write-Error "Failed to reach Artifactory at ${ServerUrl}: $_"
    exit 1
}

# Query available repositories
Write-Host "Checking repositories on Artifactory..." -ForegroundColor Cyan
$repoExists = $false
$tempRepoOut = [System.IO.Path]::GetTempFileName()
$repoHttpCode = & curl.exe -s -o $tempRepoOut -w "%{http_code}" -X GET "$ServerUrl/api/repositories" -H $authHeader
$repoResp = Get-Content $tempRepoOut -Raw -ErrorAction SilentlyContinue
Remove-Item $tempRepoOut -Force -ErrorAction SilentlyContinue

if ($repoHttpCode -eq "200") {
    try {
        $repoList = $repoResp | ConvertFrom-Json
        $repoKeys = @($repoList | ForEach-Object { $_.key })
        if ($repoKeys.Count -gt 0) {
            Write-Host "Found existing repositories: $($repoKeys -join ', ')" -ForegroundColor Gray
            if ($repoKeys -contains $Repo) {
                $repoExists = $true
            } else {
                # Check for other generic/local repos
                $matchingRepo = $repoKeys | Where-Object { $_ -match "generic" -or $_ -match "local" } | Select-Object -First 1
                if ($matchingRepo) {
                    Write-Host "Notice: '$Repo' not found, switching to available local repo: '$matchingRepo'" -ForegroundColor Cyan
                    $Repo = $matchingRepo
                    $repoExists = $true
                }
            }
        } else {
            Write-Host "No repositories currently exist in this Artifactory tenant." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Could not parse repository list response." -ForegroundColor Gray
    }
} else {
    Write-Host "Repository query returned HTTP ${repoHttpCode}: $repoResp" -ForegroundColor Yellow
}

# If repo still doesn't exist, attempt to auto-create it via REST API
if (-not $repoExists) {
    Write-Host "Attempting to create generic repository '$Repo' via REST API..." -ForegroundColor Cyan
    $createPayload = "{""key"":""$Repo"",""rclass"":""local"",""packageType"":""generic"",""description"":""SEO Web Checker SDK Artifacts""}"
    $tempCreateOut = [System.IO.Path]::GetTempFileName()
    $createCode = & curl.exe -s -o $tempCreateOut -w "%{http_code}" -X PUT "$ServerUrl/api/repositories/$Repo" -H $authHeader -H "Content-Type: application/json" -d $createPayload
    $createResp = Get-Content $tempCreateOut -Raw -ErrorAction SilentlyContinue
    Remove-Item $tempCreateOut -Force -ErrorAction SilentlyContinue

    if ($createCode -in @("200", "201")) {
        Write-Host "Successfully created generic repository '$Repo'!" -ForegroundColor Green
        $repoExists = $true
    } else {
        Write-Host "Auto-creation returned HTTP ${createCode}: $createResp" -ForegroundColor Yellow
        Write-Host "`n[ACTION REQUIRED] Repository '$Repo' does not exist yet." -ForegroundColor Red
        Write-Host "Please create a Generic Local Repository in your JFrog Web UI:" -ForegroundColor Yellow
        Write-Host "  1. Log into: https://seowebchecker.jfrog.io/ui/admin/artifactory/repositories" -ForegroundColor White
        Write-Host "  2. Click 'Create a Repository' -> 'Local Repository'" -ForegroundColor White
        Write-Host "  3. Select 'Generic' as the Package Type" -ForegroundColor White
        Write-Host "  4. Set 'Repository Key' to: generic-local (or your preferred name)" -ForegroundColor White
        Write-Host "  5. Click 'Create Local Repository'" -ForegroundColor White
        Write-Host "  6. Re-run this script: .\publish_jfrog.bat -Token <TOKEN> -Repo generic-local`n" -ForegroundColor Cyan
        exit 1
    }
}

# List of all package files to deploy
$artifacts = @(
    @{ Path = "python/dist/seowebchecker_seoaudit_sdk-1.0.0-py3-none-any.whl"; Target = "python/seowebchecker_seoaudit_sdk-1.0.0-py3-none-any.whl" },
    @{ Path = "python/dist/seowebchecker_seoaudit_sdk-1.0.0.tar.gz"; Target = "python/seowebchecker_seoaudit_sdk-1.0.0.tar.gz" },
    @{ Path = "dotnet/nupkg/SeoWebChecker.SeoAudit.1.0.0.nupkg"; Target = "nuget/SeoWebChecker.SeoAudit.1.0.0.nupkg" },
    @{ Path = "ruby/seowebchecker-seoaudit-sdk-1.0.0.gem"; Target = "ruby/seowebchecker-seoaudit-sdk-1.0.0.gem" },
    @{ Path = "chocolatey/seowebchecker.1.0.0.nupkg"; Target = "chocolatey/seowebchecker.1.0.0.nupkg" },
    @{ Path = "conda/dist/noarch/seowebchecker-seoaudit-sdk-1.0.0-py_0.tar.bz2"; Target = "conda/seowebchecker-seoaudit-sdk-1.0.0-py_0.tar.bz2" },
    @{ Path = "haskell/dist/seowebchecker-1.0.0.tar.gz"; Target = "haskell/seowebchecker-1.0.0.tar.gz" },
    @{ Path = "r/seowebchecker_1.0.0.tar.gz"; Target = "r/seowebchecker_1.0.0.tar.gz" }
)

Write-Host "`nDeploying artifacts to repository: $Repo..." -ForegroundColor Cyan

$successCount = 0
$failCount = 0

foreach ($art in $artifacts) {
    if (Test-Path $art.Path) {
        $targetUri = "$ServerUrl/$Repo/$($art.Target)"
        Write-Host "Uploading $($art.Path) -> $targetUri" -ForegroundColor Gray

        $tempOut = [System.IO.Path]::GetTempFileName()
        $httpCode = & curl.exe -s -o $tempOut -w "%{http_code}" -X PUT $targetUri -T $art.Path -H $authHeader
        $respBody = Get-Content $tempOut -Raw -ErrorAction SilentlyContinue
        Remove-Item $tempOut -Force -ErrorAction SilentlyContinue

        if ($httpCode -in @("200", "201")) {
            Write-Host " -> Successfully deployed $($art.Target) (HTTP $httpCode)" -ForegroundColor Green
            $successCount++
        } else {
            Write-Host " -> Upload error on $($art.Target) (HTTP $httpCode): $respBody" -ForegroundColor Red
            $failCount++
        }
    } else {
        Write-Host " -> Skipping $($art.Path) (file not found)" -ForegroundColor Yellow
    }
}

$statusColor = if ($failCount -eq 0) { "Green" } else { "Yellow" }
Write-Host "`nDeployment completed: $successCount succeeded, $failCount failed." -ForegroundColor $statusColor
Write-Host "Browse your repository at: $ServerUrl/#/artifacts/browse/tree/General/$Repo" -ForegroundColor Yellow
