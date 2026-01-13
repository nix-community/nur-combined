{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchzip,
  mono,
  msbuild,
  makeWrapper,
  perl,
  libgdiplus,
  fontconfig,
  rocksmith-custom-song-toolkit,
}:

let
  commandLineParser = fetchzip {
    url = "https://www.nuget.org/api/v2/package/CommandLineParser/1.9.71";
    hash = "sha256-q+wwMRO90T1E3QV8quT5cJo9CHUagX277PD1sNowuVg=";
    extension = "zip";
    stripRoot = false;
  };

  newtonsoftJson = fetchzip {
    url = "https://www.nuget.org/api/v2/package/Newtonsoft.Json/13.0.4";
    hash = "sha256-+nd5WU/JDMxGEsYIk4GGRH3HfT0a9/gSmnjrXgALGhg=";
    extension = "zip";
    stripRoot = false;
  };

  zlibNet = fetchzip {
    url = "https://www.nuget.org/api/v2/package/zlib.net/1.0.4.0";
    hash = "sha256-aRHaQ8UvBcLc7Os+ZrORKMNtP3X17iq4UP7MGdy7Mwo=";
    extension = "zip";
    stripRoot = false;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "rocksmith2tab";
  version = "0-unstable-20250126";

  src = fetchFromGitHub {
    owner = "spontiroli";
    repo = "rocksmith2tab";
    rev = "4fae27f636089ebba35f1c96c202680ac84857bb";
    hash = "sha256-GYTuqycyuiTdiotBWh6XMUy4u+/uhBGsWeJKg1yPLi0=";
  };

  nativeBuildInputs = [
    mono
    msbuild
    makeWrapper
    perl
  ];

  buildInputs = [
    libgdiplus
    fontconfig
    rocksmith-custom-song-toolkit
  ];

  postPatch = ''
    # Drop any bundled DLLs to avoid using prebuilt blobs.
    find . -type f -iname '*.dll' -delete
    cp ${rocksmith-custom-song-toolkit}/lib/rocksmith-custom-song-toolkit/lib/RocksmithToolkitLib.dll \
      libraries/RocksmithToolkitLib.dll

    if [ ! -e RocksmithToTabLib/PsarcBrowser.cs ]; then
      ln -s PSARCBrowser.cs RocksmithToTabLib/PsarcBrowser.cs
    fi

    substituteInPlace RocksmithToTabLib/RocksmithToTabLib.csproj \
      --replace-fail "Newtonsoft.Json.13.0.3" "Newtonsoft.Json.13.0.4"
    substituteInPlace RocksmithToTabLib/packages.config \
      --replace-fail "version=\"13.0.3\"" "version=\"13.0.4\""

    mkdir -p packages/CommandLineParser.1.9.71 packages/Newtonsoft.Json.13.0.4 packages/zlib.net.1.0.4.0
    cp -R ${commandLineParser}/* packages/CommandLineParser.1.9.71/
    cp -R ${newtonsoftJson}/* packages/Newtonsoft.Json.13.0.4/
    cp -R ${zlibNet}/* packages/zlib.net.1.0.4.0/
  '';

  buildPhase = ''
    runHook preBuild

    export HOME="$TMPDIR"
    export XDG_CACHE_HOME="$TMPDIR"
    export FONTCONFIG_FILE="${fontconfig.out}/etc/fonts/fonts.conf"
    export FONTCONFIG_PATH="${fontconfig.out}/etc/fonts"

    buildOut="$PWD/build-out"
    mkdir -p "$buildOut"

    msbuild RocksmithToTabLib/RocksmithToTabLib.csproj \
      /p:Configuration=Release \
      /p:Platform=AnyCPU \
      /p:RunPostBuildEvent=Never \
      /p:OutputPath="$buildOut/RocksmithToTabLib/" \
      /p:BaseIntermediateOutputPath="$buildOut/RocksmithToTabLib/obj/"

    msbuild RocksmithToTab/RocksmithToTab.csproj \
      /p:Configuration=Release \
      /p:Platform=AnyCPU \
      /p:GenerateManifests=false \
      /p:SignManifests=false \
      /p:RunPostBuildEvent=Never \
      /p:OutputPath="$buildOut/RocksmithToTab/" \
      /p:BaseIntermediateOutputPath="$buildOut/RocksmithToTab/obj/"

    msbuild RocksmithToTabGUI/RocksmithToTabGUI.csproj \
      /p:Configuration=Release \
      /p:Platform=AnyCPU \
      /p:GenerateManifests=false \
      /p:SignManifests=false \
      /p:RunPostBuildEvent=Never \
      /p:OutputPath="$buildOut/RocksmithToTabGUI/" \
      /p:BaseIntermediateOutputPath="$buildOut/RocksmithToTabGUI/obj/" || true

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    root="$out/lib/rocksmith2tab"
    mkdir -p "$root" "$out/bin"

    if [ -d build-out/RocksmithToTab ]; then
      mkdir -p "$root/RocksmithToTab"
      cp -R build-out/RocksmithToTab/* "$root/RocksmithToTab/"
      makeWrapper ${mono}/bin/mono "$out/bin/rocksmith2tab" \
        --add-flags "$root/RocksmithToTab/RocksmithToTab.exe" \
        --chdir "$root/RocksmithToTab"
    fi

    if [ -d build-out/RocksmithToTabGUI ]; then
      mkdir -p "$root/RocksmithToTabGUI"
      cp -R build-out/RocksmithToTabGUI/* "$root/RocksmithToTabGUI/"
      makeWrapper ${mono}/bin/mono "$out/bin/rocksmith2tab-gui" \
        --add-flags "$root/RocksmithToTabGUI/RocksmithToTabGUI.exe" \
        --chdir "$root/RocksmithToTabGUI"
    fi

    runHook postInstall
  '';

  meta = {
    description = "Convert Rocksmith songs to Guitar Pro tab (CLI and GUI)";
    homepage = "https://github.com/spontiroli/rocksmith2tab";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
