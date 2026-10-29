$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
Write-Host "SEOWebChecker SEO Audit CLI installed successfully!" -ForegroundColor Green
Write-Host "Run 'seowebchecker <url>' or visit https://seowebchecker.com/ for full reports." -ForegroundColor Cyan
