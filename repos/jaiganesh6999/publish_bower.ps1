# SEOWebChecker Bower Installation & Distribution Guide
# Official Website: https://seowebchecker.com/

$RepoSlug = "jaiganesh6999/seowebchecker-seoaudit-sdk"
$RepoUrl = "https://github.com/$RepoSlug.git"

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  SEOWebChecker: Bower Package Distribution Status        " -ForegroundColor Cyan
Write-Host "=========================================================`n" -ForegroundColor Cyan

Write-Host "[IMPORTANT NOTE ABOUT BOWER.IO REGISTRY]" -ForegroundColor Yellow
Write-Host "The public Bower central registry (registry.bower.io) was permanently"
Write-Host "deprecated and closed to NEW package registrations by the Bower team."
Write-Host "The registry returns HTTP 500 on all new registration attempts.`n"

Write-Host "[HOW BOWER PACKAGES ARE DISTRIBUTED TODAY]" -ForegroundColor Green
Write-Host "Bower natively supports GitHub repository packages directly without needing"
Write-Host "central registry registration. Because our repository contains a valid"
Write-Host "'bower.json' and 'dist/seowebchecker.js' at the root, any developer can"
Write-Host "install SEOWebChecker using standard Bower commands:`n"

Write-Host "Option 1 (GitHub Slug):" -ForegroundColor Cyan
Write-Host "  bower install $RepoSlug --save`n" -ForegroundColor White

Write-Host "Option 2 (Full Git URL):" -ForegroundColor Cyan
Write-Host "  bower install $RepoUrl --save`n" -ForegroundColor White

Write-Host "Option 3 (Specific Release Tag):" -ForegroundColor Cyan
Write-Host "  bower install $RepoSlug#v1.0.3 --save`n" -ForegroundColor White

Write-Host "[HTML USAGE AFTER INSTALLATION]" -ForegroundColor Green
Write-Host @"
<script src="bower_components/seowebchecker-seoaudit-sdk/dist/seowebchecker.min.js"></script>
<script>
  // Instant on-page SEO diagnostics
  const report = SEOWebChecker.auditCurrentPage();
  console.log('Score:', report.score.overall, 'Grade:', report.score.grade);
</script>
"@ -ForegroundColor Gray

Write-Host "`nMake sure your latest commits and tags are pushed to GitHub:" -ForegroundColor Yellow
Write-Host "  git push origin main --tags`n" -ForegroundColor White
