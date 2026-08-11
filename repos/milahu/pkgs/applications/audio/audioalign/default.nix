# FIXME source build

{ lib
, stdenvNoCC
, buildDotnetModule
, fetchurl
, fetchFromGitHub
, unzip
, wineWowPackages
}:

if true then

# binary build

/*
TODO use a shared read-only WINEPREFIX in /nix/store
see also
https://github.com/milahu/nixpkgs/issues/47
wine: $WINEPREFIX is not owned by you
*/

let wine = wineWowPackages.unstableFull; in

stdenvNoCC.mkDerivation rec {
  pname = "audioalign-bin";
  version = "1.7.0";

  src = fetchurl {
    url = "https://github.com/protyposis/AudioAlign/releases/download/v${version}/AudioAlign-Release-v${version}.zip";
    hash = "sha256-uSJsfF6+nG5HvyMZLi0HKLriDtCpNc1a+lHIyvj6TBY=";
  };

  nativeBuildInputs = [
    unzip
  ];

  buildCommand = ''
    mkdir -p $out/opt/audioalign
    cd $out/opt/audioalign
    unzip $src
    mkdir -p $out/bin
    cat >$out/bin/audioalign <<EOF
    #!/bin/sh
    exec ${wine}/bin/wine $out/opt/audioalign/AudioAlign.exe "$@"
    EOF
    chmod +x $out/bin/audioalign
  '';
  
  meta = with lib; {
    description = "Audio Synchronization and Analysis Tool [binary build]";
    homepage = "https://github.com/protyposis/AudioAlign";
    changelog = "https://github.com/protyposis/AudioAlign/raw/v${version}/CHANGELOG.md";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "audioalign";
    platforms = platforms.all;
  };
}

else

# source build

buildDotnetModule rec {
  pname = "audioalign";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "protyposis";
    repo = "AudioAlign";
    rev = "v${version}";
    hash = "sha256-inrNogMq/Ai4FQ0tam2JpvIgZ1vt4AczleOzFnlIsxI=";
    fetchSubmodules = true;
  };

  projectFile = "AudioAlign.sln";

  /*
  fix:

  /nix/store/3p2v489xyw5kzbrc4mk1mya8sdbcpkyx-dotnet-sdk-6.0.421/
  sdk/6.0.421/Sdks/Microsoft.NET.Sdk/targets/Microsoft.NET.Sdk.FrameworkReferenceResolution.targets(90,5):
  error NETSDK1100:
  To build a project targeting Windows on this operating system, set the EnableWindowsTargeting property to true.
  [/tmp/deps-audioalign-RgzrB2/src/AudioAlign/AudioAlign.csproj]
  */

  postPatch = ''
    substituteInPlace AudioAlign/AudioAlign.csproj \
      --replace \
        "<TargetFramework>net6.0-windows</TargetFramework>" \
        "<TargetFramework>net6.0-windows</TargetFramework><EnableWindowsTargeting>true</EnableWindowsTargeting>" \
  '';

  # FIXME race condition
  # $ nix-build . -A audioalign.fetch-deps
  # error: Defining the `nugetDeps` attribute is required
  # quickfix: empty file deps.nix

  nugetDeps = ./deps.nix;

  meta = with lib; {
    description = "Audio Synchronization and Analysis Tool";
    homepage = "https://github.com/protyposis/AudioAlign";
    changelog = "https://github.com/protyposis/AudioAlign/blob/${src.rev}/CHANGELOG.md";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "audioalign";
    platforms = platforms.all;
  };
}
