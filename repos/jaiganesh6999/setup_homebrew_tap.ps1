param(
    [string]$GitHubUser = "jaiganesh6999",
    [string]$TapRepo = "homebrew-tap",
    [string]$GitCmd = "git"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$formulaSource = Join-Path $scriptDir "Formula"

Write-Host "Homebrew Tap Setup for SEOWebChecker" -ForegroundColor Cyan
Write-Host "Formula source: $formulaSource" -ForegroundColor Gray

# Locate git executable
$gitExe = if (Get-Command $GitCmd -ErrorAction SilentlyContinue) { $GitCmd } else {
    "C:\Users\rinki\AppData\Local\GitHubDesktop\app-3.6.6\resources\app\git\cmd\git.exe"
}

if (-not (Test-Path $gitExe) -and -not (Get-Command $gitExe -ErrorAction SilentlyContinue)) {
    Write-Error "Git executable not found."
    exit 1
}

$tapDir = Join-Path $env:TEMP "homebrew-tap-seowebchecker"
if (Test-Path $tapDir) {
    Remove-Item $tapDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Preparing local tap repository at: $tapDir..." -ForegroundColor Cyan

$cloneSuccess = $false
try {
    & $gitExe clone "https://github.com/$GitHubUser/$TapRepo.git" $tapDir 2>$null
    if ($LASTEXITCODE -eq 0 -and (Test-Path $tapDir)) {
        $cloneSuccess = $true
    }
} catch {
    $cloneSuccess = $false
}

if (-not $cloneSuccess) {
    New-Item -ItemType Directory -Path $tapDir -Force | Out-Null
    Set-Location $tapDir
    & $gitExe init -b main
    & $gitExe remote add origin "https://github.com/$GitHubUser/$TapRepo.git"
} else {
    Set-Location $tapDir
}

$destFormula = Join-Path $tapDir "Formula"
if (-not (Test-Path $destFormula)) {
    New-Item -ItemType Directory -Path $destFormula -Force | Out-Null
}

Copy-Item (Join-Path $formulaSource "*.rb") $destFormula -Force

# Create README.md for the Tap
$tapReadme = @"
# Homebrew Tap for SEOWebChecker

Official Homebrew Formulae for [SEOWebChecker](https://seowebchecker.com/) tools and SDKs.

## Installation

```bash
brew tap $GitHubUser/tap
brew install seowebchecker
```

Or install directly in one step:

```bash
brew install $GitHubUser/tap/seowebchecker
```

## Available Commands

After installation, the CLI is available as:
- `seowebchecker <url>`
- `seowebchecker-audit <url>`

## Links
- Official Website: [https://seowebchecker.com/](https://seowebchecker.com/)
- Documentation: [https://seo-ai-tools.readthedocs.io/en/latest/](https://seo-ai-tools.readthedocs.io/en/latest/)
- Core SDK Repository: [https://github.com/$GitHubUser/seowebchecker-seoaudit-sdk](https://github.com/$GitHubUser/seowebchecker-seoaudit-sdk)
"@

Set-Content -Path (Join-Path $tapDir "README.md") -Value $tapReadme -Encoding UTF8

& $gitExe add -A
& $gitExe commit -m "feat: add SEOWebChecker Homebrew formulae (v1.0.1)" 2>$null

Write-Host "`nHomebrew Tap prepared!" -ForegroundColor Green
Write-Host "To push to GitHub, run:" -ForegroundColor Cyan
Write-Host "  cd '$tapDir'" -ForegroundColor White
Write-Host "  & '$gitExe' push -u origin main`n" -ForegroundColor White

Set-Location $scriptDir
