# Packaging Script for KDE Plasma Widget (Plasmoid)
# Produces org.kde.plasma.seowebchecker.plasmoid

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$kdeDir = $PSScriptRoot
if (-not $kdeDir) { $kdeDir = "C:\Users\rinki\.gemini\antigravity\scratch\seowebchecker-seoaudit-sdk\kde" }

$plasmoidFile = Join-Path $kdeDir "org.kde.plasma.seowebchecker.plasmoid"
if (Test-Path $plasmoidFile) { Remove-Item -Force $plasmoidFile }

$files = @(
    "metadata.json",
    "contents/config/config.qml",
    "contents/config/main.xml",
    "contents/code/seoengine.js",
    "contents/ui/main.qml",
    "contents/ui/CompactRepresentation.qml",
    "contents/ui/FullRepresentation.qml",
    "contents/ui/ConfigGeneral.qml"
)

$fileStream = [System.IO.File]::Create($plasmoidFile)
$archive = New-Object System.IO.Compression.ZipArchive($fileStream, [System.IO.Compression.ZipArchiveMode]::Create)

foreach ($f in $files) {
    $fullPath = Join-Path $kdeDir ($f.Replace('/', '\'))
    if (-not (Test-Path $fullPath)) {
        Write-Error "Missing required widget file: $fullPath"
        continue
    }

    # Ensure forward slashes for Linux Plasma compatibility
    $entryName = $f.Replace('\', '/')
    $entry = $archive.CreateEntry($entryName, [System.IO.Compression.CompressionLevel]::Optimal)

    $entryStream = $entry.Open()
    $contentStream = [System.IO.File]::OpenRead($fullPath)
    $contentStream.CopyTo($entryStream)
    $contentStream.Close()
    $entryStream.Close()
}

$archive.Dispose()
$fileStream.Close()

Write-Host "Created KDE Plasma Widget Package: $plasmoidFile"
$check = [System.IO.Compression.ZipFile]::OpenRead($plasmoidFile)
$check.Entries | Select-Object FullName
$check.Dispose()
