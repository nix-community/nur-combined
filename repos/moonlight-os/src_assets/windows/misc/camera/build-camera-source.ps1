param(
  [string]$OutputDirectory = (Join-Path $PSScriptRoot 'bin'),
  [string]$WorkDirectory = (Join-Path $env:TEMP 'moonlight-os-windows-camera-790ac218')
)
$ErrorActionPreference = 'Stop'
$commit = '790ac218eba8b6995393e9cc9537dfd7730fdb83'
$repository = 'https://github.com/microsoft/Windows-Camera.git'
$solution = Join-Path $WorkDirectory 'Samples\VirtualCamera\VirtualCameraSample.sln'
$patchFile = Join-Path $PSScriptRoot 'moonlight-os-camera.patch'
if (-not (Test-Path -LiteralPath $WorkDirectory -PathType Container)) {
  & git clone --filter=blob:none --no-checkout $repository $WorkDirectory
  if ($LASTEXITCODE -ne 0) { throw "Failed to clone Windows-Camera into $WorkDirectory" }
  & git -C $WorkDirectory checkout $commit
  if ($LASTEXITCODE -ne 0) { throw "Failed to check out Windows-Camera revision $commit" }
}
$revision = & git -C $WorkDirectory rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw "Failed to inspect Windows-Camera revision in $WorkDirectory" }
if ($revision.Trim() -ne $commit) {
  throw "Unexpected Windows-Camera revision in $WorkDirectory"
}
$relativeSources = @(
  'Samples\VirtualCamera\VirtualCameraMediaSource\VirtualCameraMediaSource.h',
  'Samples\VirtualCamera\VirtualCameraMediaSource\SimpleMediaStream.cpp',
  'Samples\VirtualCamera\VirtualCameraMediaSource\SimpleFrameGenerator.cpp',
  'Samples\VirtualCamera\VirtualCameraTest\SimpleMediaSourceUT.cpp',
  'Samples\VirtualCamera\VirtualCamera_Installer\main.cpp'
)
foreach ($relative in $relativeSources) {
  $path = Join-Path $WorkDirectory $relative
  $content = [IO.File]::ReadAllText($path).Replace("`r`n", "`n")
  [IO.File]::WriteAllText($path, $content, [Text.UTF8Encoding]::new($false))
}
if (-not (Select-String -LiteralPath (Join-Path $WorkDirectory $relativeSources[0]) -Quiet -SimpleMatch 'B7A32F78')) {
  Push-Location $WorkDirectory
  try {
    & patch --batch -p1 -i $patchFile
    if ($LASTEXITCODE -ne 0) { throw "Failed to apply $patchFile" }
  } finally { Pop-Location }
}
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (-not (Test-Path -LiteralPath $vswhere)) { throw 'Visual Studio Build Tools were not found' }
$msbuild = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -find 'MSBuild\**\Bin\MSBuild.exe' | Select-Object -First 1
if (-not $msbuild) { throw 'MSBuild with the C++ toolchain was not found' }
$solutionDirectory = (Split-Path -Parent $solution) + [IO.Path]::DirectorySeparatorChar
$solutionDirectoryArgument = "/p:SolutionDir=$solutionDirectory"
& $msbuild $solution /t:Restore /p:RestorePackagesConfig=true /p:Configuration=Release /p:Platform=x64 /m
if ($LASTEXITCODE -ne 0) { throw 'Failed to restore Windows-Camera packages' }
& $msbuild (Join-Path $WorkDirectory 'Samples\VirtualCamera\VirtualCameraMediaSource\VirtualCameraMediaSource.vcxproj') $solutionDirectoryArgument /p:Configuration=Release /p:Platform=x64 /m
if ($LASTEXITCODE -ne 0) { throw 'Failed to build the virtual camera media source' }
& $msbuild (Join-Path $WorkDirectory 'Samples\VirtualCamera\VirtualCamera_Installer\VirtualCamera_Installer.vcxproj') $solutionDirectoryArgument /p:Configuration=Release /p:Platform=x64 /m
if ($LASTEXITCODE -ne 0) { throw 'Failed to build the virtual camera installer' }
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
Copy-Item -Force (Join-Path $WorkDirectory 'Samples\VirtualCamera\x64\Release\VirtualCameraMediaSource.dll') (Join-Path $OutputDirectory 'MoonlightOSCameraSource.dll')
Copy-Item -Force (Join-Path $WorkDirectory 'Samples\VirtualCamera\x64\Release\VirtualCamera_Installer.exe') (Join-Path $OutputDirectory 'MoonlightOSCameraInstaller.exe')
