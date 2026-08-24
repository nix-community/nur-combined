$ErrorActionPreference = 'Stop'

# Upstream warns that 0.9.7.8 can corrupt memory and BSOD. The packaged
# 0.9.7.7 installer is hash-verified by CMake before it reaches this script.
$known = @(
    (Join-Path $env:ProgramFiles 'USBip\usbip.exe'),
    (Join-Path $env:ProgramFiles 'usbip-win2\usbip.exe')
)
$installed = $known | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if ($null -ne $installed) {
    $installedVersion = (Get-Item -LiteralPath $installed).VersionInfo.ProductVersion
    if ($installedVersion -notmatch '^0\.9\.7\.8(?:\D|$)') {
        Write-Host "usbip-win2 $installedVersion is already installed."
        exit 0
    }
    Write-Warning 'Replacing usbip-win2 0.9.7.8 because upstream warns it can corrupt memory and BSOD.'
}

$installer = Join-Path $PSScriptRoot 'USBip-0.9.7.7-x64.exe'
if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) {
    throw "The packaged usbip-win2 installer is missing: $installer"
}

$process = Start-Process -FilePath $installer `
    -ArgumentList '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/SP-' `
    -Wait -PassThru
if ($process.ExitCode -notin @(0, 3010)) {
    throw "usbip-win2 installation failed with exit code $($process.ExitCode)"
}
if ($process.ExitCode -eq 3010) {
    Write-Warning 'usbip-win2 installed successfully; Windows must reboot before USB passthrough is available.'
}

$installed = $known | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if ($null -eq $installed) {
    throw 'usbip-win2 reported success but usbip.exe was not installed.'
}
$installedVersion = (Get-Item -LiteralPath $installed).VersionInfo.ProductVersion
if ($installedVersion -match '^0\.9\.7\.8(?:\D|$)') {
    throw 'The unsafe usbip-win2 0.9.7.8 installation remains; remove it before reinstalling Helios.'
}
