@echo off
where python >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    python -m seowebchecker_seoaudit.cli %*
    exit /b %ERRORLEVEL%
)
where node >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    npx seowebchecker-seoaudit-sdk %*
    exit /b %ERRORLEVEL%
)
echo Neither Python nor Node.js was found on PATH.
echo Please install Python (choco install python) or Node.js (choco install nodejs).
exit /b 1
