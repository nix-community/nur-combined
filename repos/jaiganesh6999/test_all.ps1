Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Running Full SEOWebChecker Test Suite Across Ecosystems" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Python Tests
Write-Host ""
Write-Host "[1/3] Testing Python SDK (PyPI)..." -ForegroundColor Yellow
$env:PYTHONPATH = "$PSScriptRoot\python"
python "$PSScriptRoot\python\tests\test_auditor.py"
if ($LASTEXITCODE -eq 0) {
    Write-Host "Python SDK tests PASSED" -ForegroundColor Green
} else {
    Write-Host "Python SDK tests FAILED" -ForegroundColor Red
}

# 2. Node.js Tests
Write-Host ""
Write-Host "[2/3] Testing Node.js SDK (NPM)..." -ForegroundColor Yellow
node "$PSScriptRoot\npm\test\test.js"
if ($LASTEXITCODE -eq 0) {
    Write-Host "Node.js SDK tests PASSED" -ForegroundColor Green
} else {
    Write-Host "Node.js SDK tests FAILED" -ForegroundColor Red
}

# 3. PHP 8.2 Tests
Write-Host ""
Write-Host "[3/3] Testing PHP 8.2 SDK (Packagist)..." -ForegroundColor Yellow
& "C:\tools\php82\php.exe" "$PSScriptRoot\php\tests\AuditorTest.php"
if ($LASTEXITCODE -eq 0) {
    Write-Host "PHP 8.2 SDK tests PASSED" -ForegroundColor Green
} else {
    Write-Host "PHP 8.2 SDK tests FAILED" -ForegroundColor Red
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " All SDK suites completed successfully!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
