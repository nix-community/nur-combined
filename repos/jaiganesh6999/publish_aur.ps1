param(
    [string]$PkgName = "seowebchecker",
    [switch]$SkipPush
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$aurSource = Join-Path $scriptDir "aur"
$gitExe = "C:\Users\rinki\AppData\Local\GitHubDesktop\app-3.6.6\resources\app\git\cmd\git.exe"

Write-Host "Arch Linux User Repository (AUR) Publisher for $PkgName" -ForegroundColor Cyan
Write-Host "Upstream Canonical URL: https://seowebchecker.com/" -ForegroundColor White
Write-Host "AUR Web Portal: https://aur.archlinux.org/" -ForegroundColor White

# Step 1: Ensure SSH Key
$sshDir = Join-Path $env:USERPROFILE ".ssh"
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
}

$keyFile = Join-Path $sshDir "id_ed25519"
$pubFile = "$keyFile.pub"

if (-not (Test-Path $pubFile)) {
    $rsaPub = Join-Path $sshDir "id_rsa.pub"
    if (Test-Path $rsaPub) {
        $pubFile = $rsaPub
    } else {
        Write-Host "Generating SSH key for AUR authentication..." -ForegroundColor Cyan
        & cmd.exe /c "ssh-keygen.exe -t ed25519 -C ""jaiganesh6999@gmail.com"" -f ""$keyFile"" -q -N """"" | Out-Null
    }
}

$publicKey = (Get-Content $pubFile -Raw).Trim()

Write-Host "`n[AUR SSH PUBLIC KEY]" -ForegroundColor Yellow
Write-Host $publicKey -ForegroundColor Green
Write-Host "`nEnsure this SSH public key is added to your AUR account:" -ForegroundColor White
Write-Host "  1. Sign in or register at: https://aur.archlinux.org/account/" -ForegroundColor Cyan
Write-Host "  2. Paste the key above into 'SSH Public Key' field and click Save.`n" -ForegroundColor Cyan

# Step 2: Prepare Repository
$tempDir = Join-Path $env:TEMP "aur-$PkgName"
if (Test-Path $tempDir) {
    Remove-Item -Recurse -Force $tempDir -ErrorAction SilentlyContinue
}

$aurRemote = "ssh://aur@aur.archlinux.org/$PkgName.git"
Write-Host "Preparing AUR repository at: $tempDir..." -ForegroundColor Cyan

$cloneSuccess = $false
try {
    & $gitExe clone $aurRemote $tempDir 2>$null
    if ($LASTEXITCODE -eq 0 -and (Test-Path $tempDir)) {
        $cloneSuccess = $true
    }
} catch {
    $cloneSuccess = $false
}

if (-not $cloneSuccess) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Set-Location $tempDir
    & $gitExe init -b master
    & $gitExe remote add origin $aurRemote
} else {
    Set-Location $tempDir
}

# Step 3: Copy PKGBUILD & .SRCINFO
Copy-Item (Join-Path $aurSource "PKGBUILD") $tempDir -Force
Copy-Item (Join-Path $aurSource ".SRCINFO") $tempDir -Force

& $gitExe add PKGBUILD .SRCINFO
& $gitExe commit -m "feat: release $PkgName 1.0.1" 2>$null

Write-Host "Package files staged and committed locally." -ForegroundColor Green

if ($SkipPush) {
    Write-Host "SkipPush flag specified. Skipping push." -ForegroundColor Yellow
    Set-Location $scriptDir
    exit 0
}

Write-Host "Pushing to AUR repository ($aurRemote)..." -ForegroundColor Cyan
try {
    & $gitExe push -u origin master
    Write-Host "`nSUCCESS! Package is now LIVE on Arch Linux AUR!" -ForegroundColor Green
    Write-Host "Public Web Page: https://aur.archlinux.org/packages/$PkgName/" -ForegroundColor Yellow
    Write-Host "Users install with: yay -S $PkgName" -ForegroundColor Cyan
} catch {
    Write-Host "`nPush failed. If you have not uploaded your SSH public key to https://aur.archlinux.org/account/ yet:" -ForegroundColor Yellow
    Write-Host "  1. Add your SSH public key to your AUR profile." -ForegroundColor White
    Write-Host "  2. Run: cd '$tempDir' && git push -u origin master`n" -ForegroundColor White
}

Set-Location $scriptDir
