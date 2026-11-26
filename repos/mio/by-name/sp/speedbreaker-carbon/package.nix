# Upstream's setup_tools.sh fetches tools and needs the proprietary default.xex.
# Nix pins and builds the tools here; the first-run launcher reproduces those
# source-generation steps after checking the exact supported disc executable.
{
  lib,
  stdenv,
  stdenvNoCC,
  clangStdenv,
  clang,
  fetchFromGitHub,
  fetchurl,
  cmake,
  ninja,
  pkg-config,
  nasm,
  perl,
  binutils,
  python3,
  extract-xiso,
  sdl3,
  glslang,
  vulkan-headers,
  vulkan-loader,
  moltenvk,
  coreutils,
  findutils,
  gnugrep,
  makeWrapper,
  copyDesktopItems,
  makeDesktopItem,
  writeShellApplication,
  nix,
  git,
}:

let
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "SpeedBreakerProject";
    repo = "speedbreaker-carbon";
    tag = "v${version}";
    hash = "sha256-FwGn58mRYJ9R4UNi5G2Gf8tXjmmXx6PdtKVI/e8m0XI=";
  };

  # SpeedBreaker's setup script pins XenonRecomp independently of its release
  # tag. Keep the revision here in sync with src/scripts/setup_tools.sh.
  xenonrecompSrc = fetchFromGitHub {
    owner = "hedge-dev";
    repo = "XenonRecomp";
    rev = "ddd128bcca99fe8bfbb99bea583c972351fa6ace";
    fetchSubmodules = true;
    hash = "sha256-suzrnFuHlDrrUWx70jJBNOJwgLpWasBrdqeth//PfWc=";
  };

  xenonrecomp = clangStdenv.mkDerivation {
    pname = "xenonrecomp-speedbreaker";
    version = "0-unstable-2025-08-04";
    src = xenonrecompSrc;

    nativeBuildInputs = [
      cmake
      ninja
    ];

    # These are SpeedBreaker's own patches for the pinned upstream revision.
    postPatch = ''
      for patchFile in ${src}/patches/xenonrecomp/*.patch; do
        patch -p1 < "$patchFile"
      done
    '';

    cmakeFlags = [
      "-DCMAKE_BUILD_TYPE=Release"
    ];

    env.CXXFLAGS = "-include cstdlib";

    buildPhase = ''
      runHook preBuild
      cmake --build . --target XenonRecomp XenonAnalyse
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -Dm755 XenonRecomp/XenonRecomp "$out/bin/XenonRecomp"
      install -Dm755 XenonAnalyse/XenonAnalyse "$out/bin/XenonAnalyse"

      # The runtime build includes XenonUtils and its submodules.
      mkdir -p "$out/share"
      cp -R "$NIX_BUILD_TOP/source" "$out/share/XenonRecomp"
      rm -rf "$out/share/XenonRecomp/build"

      runHook postInstall
    '';

    meta = {
      description = "XenonRecomp with SpeedBreaker's PowerPC code generation patches";
      homepage = "https://github.com/hedge-dev/XenonRecomp";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
    };
  };

  ffmpegXma = stdenv.mkDerivation {
    pname = "ffmpeg-xma";
    version = "7.1.1";
    dontUnpack = true;
    dontConfigure = true;

    src = fetchurl {
      url = "https://ffmpeg.org/releases/ffmpeg-7.1.1.tar.xz";
      hash = "sha256-czmEOV4Nu+XARqvaLcSaVUTn4OHiNmu6hJIirp46A7E=";
    };

    nativeBuildInputs = [
      nasm
      perl
      pkg-config
      binutils
    ];

    buildPhase = ''
      runHook preBuild
      bash ${src}/scripts/build_ffmpeg_xma.sh \
        "$src" \
        "$out" \
        --cc=${stdenv.cc}/bin/cc \
        --cxx=${stdenv.cc}/bin/c++
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      runHook postInstall
    '';

    meta = {
      description = "Minimal static FFmpeg with XMA1, XMA2 and WMA Pro decoders";
      homepage = "https://ffmpeg.org";
      license = lib.licenses.lgpl21Plus;
      platforms = lib.platforms.unix;
    };
  };

  sourceBuilder = writeShellApplication {
    name = "speedbreaker-carbon-build";
    runtimeInputs = [
      clang
      cmake
      ninja
      pkg-config
      python3
      extract-xiso
      coreutils
      findutils
      gnugrep
      makeWrapper
    ];

    text = ''
      if (( $# != 3 )); then
        echo "usage: speedbreaker-carbon-build <disc-image> <source-dir> <state-dir>" >&2
        exit 2
      fi

      image="$1"
      sourceDir="$2"
      stateDir="$3"
      discDir="$sourceDir/game-carbon/files"
      buildDir="$stateDir/build"
      binary="$buildDir/runtime/SpeedBreaker"
      xex="$discDir/default.xex"
      xexHash="922c7a1a2fc77405c43aac5159ad67fb0414c872084abc3335c68dbb4bec1815"

      if [[ ! -f "$image" ]]; then
        echo "error: disc image not found: $image" >&2
        exit 1
      fi

      if [[ -f "$xex" ]] && {
        [[ "$(wc -c < "$xex")" != "4866048" ]] ||
        [[ "$(sha256sum "$xex" | cut -d' ' -f1)" != "$xexHash" ]]
      }; then
        echo "Cached default.xex is not the supported executable; extracting again."
        rm -rf "$discDir"
      fi

      install -d "$discDir"
      if [[ ! -f "$discDir/default.xex" ]]; then
        echo "Extracting the Xbox 360 disc..."
        extract-xiso -q -x -d "$discDir" "$image"
      fi

      if [[ ! -f "$xex" ]]; then
        echo "error: the disc image has no default.xex" >&2
        exit 1
      fi

      if [[ "$(wc -c < "$xex")" != "4866048" ]]; then
        echo "error: default.xex is not the supported USA Collector's Edition executable" >&2
        exit 1
      fi
      if [[ "$(sha256sum "$xex" | cut -d' ' -f1)" != "$xexHash" ]]; then
        echo "error: default.xex SHA-256 does not match the supported USA Collector's Edition" >&2
        exit 1
      fi

      rm -rf "$sourceDir/tools/XenonRecomp" "$sourceDir/tools/ffmpeg-xma"
      install -d "$sourceDir/tools"
      cp -R ${xenonrecomp}/share/XenonRecomp "$sourceDir/tools/XenonRecomp"
      cp -R ${ffmpegXma} "$sourceDir/tools/ffmpeg-xma"
      chmod -R u+w "$sourceDir/tools"

      rm -rf "$sourceDir/ppc-carbon" "$buildDir"
      install -d "$sourceDir/ppc-carbon"

      echo "Translating default.xex to C++..."
      ${xenonrecomp}/bin/XenonRecomp \
        "$sourceDir/config/carbon/carbon.toml" \
        "$sourceDir/tools/XenonRecomp/XenonUtils/ppc_context.h"

      prefixPath="${sdl3.dev}:${glslang.dev}:${vulkan-loader.dev}:${vulkan-headers}"
      cmake_args=(
        -S "$sourceDir"
        -B "$buildDir"
        -G Ninja
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_C_COMPILER=${clang}/bin/clang
        -DCMAKE_CXX_COMPILER=${clang}/bin/clang++
        -DCMAKE_PREFIX_PATH="$prefixPath"
        -DSB_GAME=carbon
        -DFFMPEG_XMA="$sourceDir/tools/ffmpeg-xma"
      )

      ${lib.optionalString stdenv.hostPlatform.isDarwin ''
        cmake_args+=(
          -DCMAKE_OSX_DEPLOYMENT_TARGET=15.0
          -DSB_MOLTENVK=${moltenvk}/lib/libMoltenVK.dylib
        )
      ''}

      echo "Configuring and compiling SpeedBreaker: Carbon..."
      cmake "''${cmake_args[@]}"
      cmake --build "$buildDir" --target SpeedBreaker

      if [[ ! -x "$binary" ]]; then
        echo "error: the build did not produce $binary" >&2
        exit 1
      fi

      echo "Built SpeedBreaker: Carbon at $binary"
    '';
  };
in
stdenvNoCC.mkDerivation {
  pname = "speedbreaker-carbon";
  inherit version src;

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ copyDesktopItems ];

  desktopItems = lib.optional stdenv.hostPlatform.isLinux (makeDesktopItem {
    name = "speedbreaker-carbon";
    desktopName = "SpeedBreaker: Carbon";
    exec = "speedbreaker-carbon";
    icon = "speedbreaker-carbon";
    comment = "Native recompilation of Need for Speed: Carbon";
    categories = [
      "Game"
      "Racing"
    ];
  });

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -d "$out/bin" "$out/libexec" "$out/share/speedbreaker-carbon"
    cp -R . "$out/share/speedbreaker-carbon/source"
    chmod -R u+w "$out/share/speedbreaker-carbon/source"

    substitute ${./launcher.sh} "$out/bin/speedbreaker-carbon" \
      --subst-var-by source ${placeholder "out"}/share/speedbreaker-carbon/source \
      --subst-var-by builder ${sourceBuilder}/bin/speedbreaker-carbon-build \
      --subst-var-by version ${version}
    chmod +x "$out/bin/speedbreaker-carbon"
    wrapProgram "$out/bin/speedbreaker-carbon" \
      --prefix PATH : ${
        lib.makeBinPath [
          stdenvNoCC.shell
          coreutils
          findutils
        ]
      }

    install -Dm644 scripts/macos/AppIcon-carbon.png \
      "$out/share/icons/hicolor/512x512/apps/speedbreaker-carbon.png"

    runHook postInstall
  '';

  passthru = {
    inherit src xenonrecompSrc ffmpegXma;
    updateScript = writeShellApplication {
      name = "update-speedbreaker-carbon";
      runtimeInputs = [
        python3
        nix
        git
        coreutils
      ];
      text = ''
        export UPDATE_NIX_ATTR_PATH="speedbreaker-carbon"
        exec ${python3}/bin/python3 ${./update.py} "$@"
      '';
    };
  };

  meta = {
    description = "Native recompilation of Need for Speed: Carbon (needs your own USA Collector's Edition disc)";
    longDescription = ''
      SpeedBreaker: Carbon is a native static recompilation of the Xbox 360
      version of Need for Speed: Carbon. Its source contains no game code or
      data. This package installs the build tools and source, then compiles
      the game executable from the default.xex on a user-supplied USA
      Collector's Edition disc image on first run.
    '';
    homepage = "https://github.com/SpeedBreakerProject/speedbreaker-carbon";
    changelog = "https://github.com/SpeedBreakerProject/speedbreaker-carbon/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "speedbreaker-carbon";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    hydraPlatforms = [ ];
  };
}
