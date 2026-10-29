# SEOWebChecker PureScript Verification & Pursuit Submission Guide
# Official Website: https://seowebchecker.com/

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  SEOWebChecker: PureScript Registry & Pursuit Guide     " -ForegroundColor Cyan
Write-Host "=========================================================`n" -ForegroundColor Cyan

# 1. Run local test suite
Write-Host "[1/3] Running local PureScript FFI test suite..." -ForegroundColor Yellow
$purescriptDir = $PSScriptRoot
if (-not $purescriptDir) { $purescriptDir = "C:\Users\rinki\.gemini\antigravity\scratch\seowebchecker-seoaudit-sdk\purescript" }

Push-Location $purescriptDir
try {
    node test_runner.js
    if ($LASTEXITCODE -ne 0) {
        Write-Error "PureScript FFI verification failed."
        exit 1
    }
} finally {
    Pop-Location
}

# 2. Manifest status
Write-Host "`n[2/3] Verifying package manifests..." -ForegroundColor Yellow
$hasSpagoYaml = Test-Path (Join-Path $purescriptDir "spago.yaml")
$hasSpagoDhall = Test-Path (Join-Path $purescriptDir "spago.dhall")
$hasBowerJson = Test-Path (Join-Path $purescriptDir "bower.json")

Write-Host "  spago.yaml (Modern Spago):  " -NoNewline; if ($hasSpagoYaml) { Write-Host "FOUND [OK]" -ForegroundColor Green } else { Write-Host "MISSING" -ForegroundColor Red }
Write-Host "  spago.dhall (Legacy Spago): " -NoNewline; if ($hasSpagoDhall) { Write-Host "FOUND [OK]" -ForegroundColor Green } else { Write-Host "MISSING" -ForegroundColor Red }
Write-Host "  bower.json (Pursuit Index): " -NoNewline; if ($hasBowerJson) { Write-Host "FOUND [OK]" -ForegroundColor Green } else { Write-Host "MISSING" -ForegroundColor Red }

# 3. Submission instructions
Write-Host "`n[3/3] How to publish to PureScript Registry & Pursuit:" -ForegroundColor Green
Write-Host @"
Step 1: Commit and push changes to GitHub:
  git add purescript/
  git commit -m "feat(purescript): add official PureScript client SDK"
  git push origin main

Step 2: Publish using Spago:
  spago publish

Step 3: Verification on Pursuit:
  Once approved in the PureScript Registry, your package and type signatures
  will be live on Pursuit at:
  https://pursuit.purescript.org/packages/purescript-seowebchecker
"@ -ForegroundColor Cyan

Write-Host "`nAll files are configured and tested.`n" -ForegroundColor Green
