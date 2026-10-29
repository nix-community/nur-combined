param(
    [string]$AppId = "com.seowebchecker.seowebchecker"
)

Write-Host "Flathub / Flatpak Publishing Helper for $AppId" -ForegroundColor Cyan
Write-Host "Flatpak manifests: flatpak/" -ForegroundColor Gray
Write-Host "Official Flathub Store: https://flathub.org/" -ForegroundColor White
Write-Host "Flathub Submissions Repo: https://github.com/flathub/flathub" -ForegroundColor White

Write-Host "`nHow to Submit to Flathub (Official Pull Request Workflow):" -ForegroundColor Yellow

Write-Host "`nStep 1: Fork and Clone" -ForegroundColor Cyan
Write-Host "  Fork https://github.com/flathub/flathub on GitHub" -ForegroundColor White
Write-Host "  git clone https://github.com/<YOUR_USER>/flathub.git" -ForegroundColor White
Write-Host "  cd flathub" -ForegroundColor White
Write-Host "  git checkout -b add-$AppId" -ForegroundColor White

Write-Host "`nStep 2: Copy Manifest Files" -ForegroundColor Cyan
Write-Host "  Copy all files from 'flatpak/' into the flathub repository:" -ForegroundColor White
Write-Host "    - $AppId.yml" -ForegroundColor Gray
Write-Host "    - $AppId.metainfo.xml" -ForegroundColor Gray
Write-Host "    - $AppId.desktop" -ForegroundColor Gray
Write-Host "    - $AppId.png" -ForegroundColor Gray

Write-Host "`nStep 3: Commit and Open Pull Request" -ForegroundColor Cyan
Write-Host "  git add ." -ForegroundColor White
Write-Host "  git commit -m 'Add $AppId'" -ForegroundColor White
Write-Host "  git push -u origin add-$AppId" -ForegroundColor White
Write-Host "  Open Pull Request at: https://github.com/flathub/flathub/pulls" -ForegroundColor Green

Write-Host "`nOnce merged, your app will be indexed at: https://flathub.org/apps/$AppId" -ForegroundColor Green
Write-Host "Installation command: flatpak install flathub $AppId" -ForegroundColor Yellow
