param(
    [string]$PortName = "seowebchecker"
)

Write-Host "MacPorts Publishing Helper for $PortName" -ForegroundColor Cyan
Write-Host "Portfile source: macports/www/$PortName/Portfile" -ForegroundColor Gray
Write-Host "Official MacPorts Registry: https://ports.macports.org/" -ForegroundColor White
Write-Host "MacPorts Ports Repository: https://github.com/macports/macports-ports" -ForegroundColor White

Write-Host "`nHow to Submit to MacPorts (Official Pull Request Workflow):" -ForegroundColor Yellow

Write-Host "`nStep 1: Fork and Clone" -ForegroundColor Cyan
Write-Host "  Fork https://github.com/macports/macports-ports on GitHub" -ForegroundColor White
Write-Host "  git clone https://github.com/<YOUR_USER>/macports-ports.git" -ForegroundColor White
Write-Host "  cd macports-ports" -ForegroundColor White
Write-Host "  git checkout -b add-$PortName" -ForegroundColor White

Write-Host "`nStep 2: Add the Portfile" -ForegroundColor Cyan
Write-Host "  mkdir -p www/$PortName" -ForegroundColor White
Write-Host "  Copy 'macports/www/$PortName/Portfile' -> 'www/$PortName/Portfile'" -ForegroundColor White

Write-Host "`nStep 3: Commit and Open Pull Request" -ForegroundColor Cyan
Write-Host "  git add www/$PortName/Portfile" -ForegroundColor White
Write-Host "  git commit -m '$PortName: new port'" -ForegroundColor White
Write-Host "  git push -u origin add-$PortName" -ForegroundColor White
Write-Host "  Open Pull Request at: https://github.com/macports/macports-ports/pulls" -ForegroundColor Green

Write-Host "`nOnce approved, your port will be indexed at: https://ports.macports.org/port/$PortName/" -ForegroundColor Green
Write-Host "Installation command: sudo port install $PortName" -ForegroundColor Yellow
