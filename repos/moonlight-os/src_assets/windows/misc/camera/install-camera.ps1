$ErrorActionPreference = 'Stop'
if ([Environment]::OSVersion.Version.Build -lt 22000) {
  Write-Output 'Moonlight OS Camera requires Windows 11 build 22000 or newer.'
  exit 0
}
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$dll = Join-Path $root 'camera\MoonlightOSCameraSource.dll'
$installer = Join-Path $root 'camera\MoonlightOSCameraInstaller.exe'
if (-not (Test-Path -LiteralPath $dll -PathType Leaf) -or
    -not (Test-Path -LiteralPath $installer -PathType Leaf)) {
  Write-Output 'Moonlight OS Camera components are not present in this package.'
  exit 0
}
$key = 'HKLM:\Software\Classes\CLSID\{B7A32F78-6B0D-4B0A-A9E5-9C8A53C79831}\InProcServer32'
New-Item -Path $key -Force | Out-Null
Set-Item -Path $key -Value $dll
New-ItemProperty -Path $key -Name ThreadingModel -Value Both -PropertyType String -Force | Out-Null
& $installer /Install
if ($LASTEXITCODE -ne 0) { throw "Virtual camera registration failed: $LASTEXITCODE" }
