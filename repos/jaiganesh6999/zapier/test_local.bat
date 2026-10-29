@echo off
setlocal
cd /d "%~dp0"
set /p TARGET_URL="Enter URL to audit (or press Enter for https://seowebchecker.com/): "
if "%TARGET_URL%"=="" set TARGET_URL=https://seowebchecker.com/
node test_local.js "%TARGET_URL%"
pause
