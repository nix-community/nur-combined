param(
    [string]$SnapName = "seowebchecker"
)

Write-Host "Snapcraft Publishing Helper for $SnapName" -ForegroundColor Cyan
Write-Host "Snap Manifest: snap/snapcraft.yaml" -ForegroundColor Gray
Write-Host "Official Canonical Snap Store: https://snapcraft.io/" -ForegroundColor White

Write-Host "`nTo publish $SnapName to the Snap Store, choose one of two methods:" -ForegroundColor Yellow

Write-Host "`nMethod 1: Canonical Cloud Build (Recommended - Zero Setup, Multi-Arch):" -ForegroundColor Cyan
Write-Host "  1. Register the snap name: https://snapcraft.io/register-snap" -ForegroundColor White
Write-Host "  2. Go to Builds: https://snapcraft.io/$SnapName/builds" -ForegroundColor White
Write-Host "  3. Click 'Connect GitHub' and select 'jaiganesh6999/seowebchecker-seoaudit-sdk'" -ForegroundColor White
Write-Host "  4. Canonical Launchpad will automatically build (amd64, arm64, armhf) and publish to stable!" -ForegroundColor Green

Write-Host "`nMethod 2: GitHub Actions Automated Release:" -ForegroundColor Cyan
Write-Host "  1. Export a store token: snapcraft export-login --snaps=$SnapName export.txt" -ForegroundColor White
Write-Host "  2. In GitHub repository Settings -> Secrets -> Actions" -ForegroundColor White
Write-Host "  3. Add secret: SNAPCRAFT_STORE_CREDENTIALS" -ForegroundColor White
Write-Host "  4. Run workflow: Actions -> 'Build and Release Snap' -> Run workflow" -ForegroundColor Green
Write-Host "`nPublic Snap Store page will be live at: https://snapcraft.io/$SnapName" -ForegroundColor Yellow
