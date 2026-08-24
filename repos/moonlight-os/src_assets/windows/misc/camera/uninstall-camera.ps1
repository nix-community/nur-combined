$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$installer = Join-Path $root 'camera\MoonlightOSCameraInstaller.exe'
if (Test-Path -LiteralPath $installer -PathType Leaf) { & $installer /Uninstall }
$key = 'HKLM:\Software\Classes\CLSID\{B7A32F78-6B0D-4B0A-A9E5-9C8A53C79831}'
if (Test-Path -LiteralPath $key) { Remove-Item -LiteralPath $key -Recurse -Force }
