/*
FIXME
the dependencies are so old, they require dotnet6.0 on runtime
but there is no dotnet6.0 desktop runtime for linux
https://dotnet.microsoft.com/en-us/download/dotnet/6.0/runtime



with dotnet6.0

$ HocrEditor
You must install or update .NET to run this application.

App: /nix/store/xi20gh0jkwyx6q4nks8k401bcdj12fv9-hocr-editor-0.3.0/lib/hocr-editor/HocrEditor
Architecture: x64
Framework: 'Microsoft.WindowsDesktop.App', version '6.0.0' (x64)
.NET location: /nix/store/bxpggsjgyshji2qsmri50irbmsv1iqib-dotnet-runtime-6.0.36/share/dotnet

No frameworks were found.



with dotnet9.0

You must install or update .NET to run this application.

App: /nix/store/l11k69b41v9qlr9xpbsa75132b8amv3p-hocr-editor-0.3.0/lib/hocr-editor/HocrEditor
Architecture: x64
Framework: 'Microsoft.NETCore.App', version '6.0.0' (x64)
.NET location: /nix/store/pjkcfa1qqvpdx35jx2h40xv2hmbkfc8z-dotnet-runtime-9.0.6/share/dotnet

The following frameworks were found:
  9.0.6 at [/nix/store/pjkcfa1qqvpdx35jx2h40xv2hmbkfc8z-dotnet-runtime-9.0.6/share/dotnet/shared/Microsoft.NETCore.App]

Learn more:
https://aka.ms/dotnet/app-launch-failed

To install missing framework, download:
https://aka.ms/dotnet-core-applaunch?framework=Microsoft.NETCore.App&framework_version=6.0.0&arch=x64&rid=linux-x64&os=nixos.25.11
*/

{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
}:

# buildDotnetPackage rec {
buildDotnetModule rec {
  pname = "hocr-editor-cs";
  # baseName = pname; # legacy
  version = "0.3.0";

  src =
  # if true then /home/user/src/milahu/nur-packages/HocrEditor else
  if true then
  # https://github.com/milahu/hocr-editor-cs
  fetchFromGitHub {
    owner = "milahu";
    repo = "hocr-editor-cs";
    rev = "9ef5a2b4c6b6ecd9855654915ec79a557349d602";
    hash = "sha256-UC8/OmvnZ7PieZysKqkjbtkg0q5wzoJBfCt+eagoKik=";
  }
  else
  fetchFromGitHub {
    owner = "GeReV";
    repo = "HocrEditor";
    rev = "v${version}";
    hash = "sha256-UMp3iI86PI/4//lrp/xOWLc5q+Exta049UbNUAnYJfg=";
  };

/*
    sed -i '/<TargetFramework>/d' HocrEditor.Tesseract/HocrEditor.Tesseract.csproj
    sed -i '/<TargetFramework>/d' HocrEditor/HocrEditor.csproj
*/
  postPatch = ''
    # fix: error NU5039: The readme file 'README.md' does not exist in the package.
    # touch HocrEditor/README.md
    sed -i '/<PackageReadmeFile>/d' HocrEditor/HocrEditor.csproj
  '';

  projectFile = "HocrEditor.sln";

  # error NU5026: The file '.../HocrEditor.runtimeconfig.json' to be packed was not found on disk. [/build/source/HocrEditor/HocrEditor.csproj]
  # projectFile = "HocrEditor/HocrEditor.csproj";

  # NuGet.Build.Tasks.Pack.targets(221,5):
  # error NU5026: The file '/build/source/HocrEditor.Tesseract/bin/Release/net6.0-windows/HocrEditor.Tesseract.dll' to be packed was not found on disk.
  # [/build/source/HocrEditor.Tesseract/HocrEditor.Tesseract.csproj]
  # projectFile = "HocrEditor.Tesseract/HocrEditor.Tesseract.csproj";

  # bash $(nix-build . -A hocr-editor.passthru.fetch-deps)
  nugetDeps = ./deps.nix;

  projectReferences = [
    # `referencedProject` must contain `nupkg` in the folder structure.
    # referencedProject
  ];

  # error MSB4019: The imported project ".../Microsoft.NET.Sdk.WindowsDesktop.targets" was not found.
  # dotnet-version = "10_0";

  # error NU5039: The readme file 'README.md' does not exist in the package.
  /*
  Running phase: installPhase
  Executing dotnetInstallHook
  /nix/store/hddfds2a8s7lp3bi35z5n24rhh8pjs2z-dotnet-sdk-9.0.205/share/dotnet/sdk/9.0.205/Current/SolutionFile/ImportAfter/Microsoft.NET.Sdk.Solution.targets(36,5): warning NETSDK1194: The "--output" option isn't supported when building a solution. Specifying a solution-level output path results in all projects copying outputs to the same directory, which can lead to inconsistent builds. [/build/source/HocrEditor.sln]
    HocrEditor.Tesseract -> /nix/store/mcchwn9rdg04i1mhd4bbi5mks9g8z4xs-hocr-editor-0.3.0/lib/hocr-editor/
    HocrEditor -> /nix/store/mcchwn9rdg04i1mhd4bbi5mks9g8z4xs-hocr-editor-0.3.0/lib/hocr-editor/
    The package HocrEditor.Tesseract.0.3.0 is missing a readme. Go to https://aka.ms/nuget/authoring-best-practices/readme to learn why package readmes are important.
    Successfully created package '/nix/store/mcchwn9rdg04i1mhd4bbi5mks9g8z4xs-hocr-editor-0.3.0/share/nuget/source/HocrEditor.Tesseract.0.3.0.nupkg'.
  /nix/store/hddfds2a8s7lp3bi35z5n24rhh8pjs2z-dotnet-sdk-9.0.205/share/dotnet/sdk/9.0.205/Sdks/NuGet.Build.Tasks.Pack/build/NuGet.Build.Tasks.Pack.targets(221,5): error NU5039: The readme file 'README.md' does not exist in the package. [/build/source/HocrEditor/HocrEditor.csproj]
  */
  # <TargetFramework>net9.0-windows</TargetFramework>
  # <TargetFramework>net9.0</TargetFramework>
  # this makes no difference
  dotnet-version = "9_0";
  # dotnet-version = "6_0";

  # The following frameworks were found:
  #   9.0.6 at [/nix/store/pjkcfa1qqvpdx35jx2h40xv2hmbkfc8z-dotnet-runtime-9.0.6/share/dotnet/shared/Microsoft.NETCore.App]
  # dotnet-runtime-version = "9_0";
  # fix: You must install or update .NET to run this application.
  # Framework: 'Microsoft.NETCore.App', version '6.0.0' (x64)
  # FIXME No frameworks were found.
  # $ nix-locate share/dotnet/shared/Microsoft.NETCore.App | grep _8_0
  # -> the oldest version with Microsoft.NETCore.App is dotnet 8.0
  # https://dotnet.microsoft.com/en-us/download/dotnet/6.0/runtime
  # -> for dotnet 6.0 there is no "desktop" runtime for linux
  # -> for windows desktop there is
  # https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/runtime-desktop-6.0.36-windows-x64-installer
  # https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/6.0.36/windowsdesktop-runtime-6.0.36-win-x64.exe
  # dotnet-runtime-version = "6_0";
  # dotnet-runtime-version = "6_0";
  dotnet-runtime-version = "9_0";

  # error MSB4018: The "GenerateDepsFile" task failed unexpectedly. [/build/source/HocrEditor.Tesseract/HocrEditor.Tesseract.csproj]
  # dotnet-version = "8_0";

  # Dotnet SDK 7.0.410 is EOL
  # dotnet-version = "7_0";

  dotnet-sdk = dotnetCorePackages."sdk_${dotnet-version}";
  dotnet-runtime = dotnetCorePackages."runtime_${dotnet-runtime-version}";

  # fix: error MSB4018: System.IO.IOException:
  # The process cannot access the file '.../HocrEditor.Tesseract.deps.json' because it is being used by another process.
  enableParallelBuilding = false;

  executables = [ "HocrEditor" ];

  # This packs the project as "foo-0.1.nupkg" at `$out/share`.
  packNupkg = true;

  runtimeDeps = [
    # This will wrap ffmpeg's library path into `LD_LIBRARY_PATH`.
    # ffmpeg
  ];

  dotnetFlags = [
    # fix: error NETSDK1100: To build a project targeting Windows on this operating system, set the EnableWindowsTargeting property to true.
    "-p:EnableWindowsTargeting=true"
  ];

  meta = {
    description = "A visual editor for .hocr files";
    homepage = "https://github.com/GeReV/HocrEditor";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "HocrEditor";
    platforms = lib.platforms.all;
  };
}
