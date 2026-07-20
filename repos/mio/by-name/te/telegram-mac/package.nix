{
  lib,
  stdenvNoCC,
  python3,
  git,
  cacert,
  cmake,
  ninja,
  openssl,
  zlib,
  autoconf,
  libtool,
  automake,
  yasm,
  nasm,
  pkg-config,
  unzip,
  meson,
  fetchzip,
  writableTmpDirAsHomeHook,
}:

# NOTE: Building TelegramSwift (the native Telegram for macOS client) from source
# is notoriously complex in a pure Nix environment. It relies heavily on Xcode,
# Swift Package Manager (which requires network access during the build), and
# specific code-signing setups.
#
# This derivation provides a foundation, but achieving a fully pure, functional
# build will likely require:
# 1. Impure builds (sandbox = false) to allow Xcode and SPM network access.
# 2. Or, a complex translation of Swift Package Manager dependencies into Nix.
# 3. Supplying valid `api_id` and `api_hash` credentials.

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "telegram-mac";
  version = "10.14"; # Update to the latest desired version

  ffmpegSrc = fetchzip {
    url = "https://ffmpeg.org/releases/ffmpeg-7.1.tar.xz";
    hash = "sha256-cNb7sIx7YIoVcamG6/cCFAdELSAm/N0OFBaJ1imJDQk=";
  };

  src = stdenvNoCC.mkDerivation {
    name = "telegram-mac-source";
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-hp1cI+6dbAWrgfgq5nNUScyDDe48E8k7GmaGWxyTCvM="; # Will need to be updated after first run

    nativeBuildInputs = [
      git
      cacert
      writableTmpDirAsHomeHook
    ];

    buildCommand = ''
      git config --global url."https://github.com/".insteadOf "git@github.com:"
      git config --global url."https://gitlab.com/".insteadOf "git@gitlab.com:"

      git clone https://github.com/overtake/TelegramSwift.git $out
      cd $out
      git checkout 579cebbf0c01fd41b712eff3647fa7f69db9665d
      git submodule update --init --recursive
      rm -rf .git
    '';
  };

  nativeBuildInputs = [
    python3
    cmake
    ninja
    openssl
    zlib
    autoconf
    libtool
    automake
    yasm
    nasm
    pkg-config
    unzip
    meson
    writableTmpDirAsHomeHook
  ];

  # Using xcodebuild directly usually requires the environment to have Xcode available.
  # This requires setting `sandbox = false` in your nix.conf for Darwin.
  __noChroot = true; # Hint for Hydra/Nix to disable sandbox if possible
  dontUseCmakeConfigure = true;
  dontUseMesonConfigure = true;

  buildPhase = ''
    runHook preBuild

    # Copy FFmpeg source
    mkdir -p submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/ffmpeg-7.1
    cp -r ${finalAttrs.ffmpegSrc}/* submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/ffmpeg-7.1/

    # Allow scripts to find xcrun and xcodebuild on the host
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export PATH=$PATH:/usr/bin:/bin:/usr/sbin:/sbin

    # CoreFoundation uses the user database for home dir, override it:
    export CFFIXED_USER_HOME=$HOME

    # Telegram for macOS requires framework configuration first
    sed -i 's/no/yes/g' scripts/rebuild || true

    # Fix CMake 3.5 compatibility for Mozjpeg
    sed -i 's/cmake_minimum_required(VERSION .*/cmake_minimum_required(VERSION 3.5)/g' submodules/telegram-ios/third-party/mozjpeg/mozjpeg/CMakeLists.txt || true

    # Fix libwebp ZIP extraction (Nix GNU tar does not support ZIP, use unzip)
    sed -i 's/tar -xzf "$SOURCE_ARCHIVE" --directory "$OUT_DIR"/unzip -q "$SOURCE_ARCHIVE" -d "$OUT_DIR"/g' core-xprojects/libwebp/libwebp/build*.sh || true

    # Fix webrtc build script to correctly copy source directory contents (avoids missing CMakeLists.txt)
    sed -i 's/cp -R \$SOURCE_DIR \$BUILD_DIR/cp -R "$SOURCE_DIR"\/. "$BUILD_DIR"\//g' core-xprojects/webrtc/webrtc/build.sh || true

    # Fix Mozjpeg build script for GNU cp
    sed -i 's/mozjpeg\/" "''${BUILD_DIR}build\/"/mozjpeg\/"\/. "''${BUILD_DIR}build\/"/g' core-xprojects/Mozjpeg/Mozjpeg/build.sh || true

    # Fix webrtc libopus include path
    sed -i 's/libopus\/build\/libopus\/include\/opus/libopus\/build\/libopus\/include\/opus\/include/g' core-xprojects/webrtc/webrtc.xcodeproj/project.pbxproj || true

    # Fix the custom pkg-config wrapper to parse custom paths properly when ffmpeg prepends them
    cat > submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/pkg-config <<'EOF'
    #!/bin/sh
    LIBOPUS_PATH=""
    LIBVPX_PATH=""
    LIBDAV1D_PATH=""
    CMD=""
    NAME=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --libopus_path) LIBOPUS_PATH="$2"; shift 2 ;;
            --libvpx_path) LIBVPX_PATH="$2"; shift 2 ;;
            --libdav1d_path) LIBDAV1D_PATH="$2"; shift 2 ;;
            --version|--exists|--cflags|--libs) CMD="$1"; shift 1 ;;
            --print-errors) shift 1 ;;
            zlib*|opus*|vpx*|dav1d*) NAME="$1"; shift 1 ;;
            *) shift 1 ;;
        esac
    done

    if [ "$CMD" == "--version" ]; then
        echo "0.29.2"
        exit 0
    elif [ "$CMD" == "--exists" ]; then
        case "$NAME" in
            zlib*|opus*|vpx*|dav1d*) exit 0 ;;
            *) exit 1 ;;
        esac
    elif [ "$CMD" == "--cflags" ]; then
        case "$NAME" in
            zlib*) echo "" ;;
            opus*) echo "-I$LIBOPUS_PATH/include/opus/include -I$LIBOPUS_PATH/include/opus" ;;
            vpx*) echo "-I$LIBVPX_PATH/include" ;;
            dav1d*) echo "-I$LIBDAV1D_PATH/include" ;;
            *) exit 1 ;;
        esac
        exit 0
    elif [ "$CMD" == "--libs" ]; then
        case "$NAME" in
            zlib*) echo "-lz" ;;
            opus*) echo "-L$LIBOPUS_PATH/lib -lopus" ;;
            vpx*) echo "-L$LIBVPX_PATH/lib -lVPX" ;;
            dav1d*) echo "-L$LIBDAV1D_PATH/lib -ldav1d" ;;
            *) exit 1 ;;
        esac
        exit 0
    else
        exit 1
    fi
    EOF
    chmod +x submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/pkg-config

    # Run the setup script
    sh scripts/configure_frameworks.sh

    set -x
    pwd

    # Fix OpusBinding header search path
    mkdir -p submodules/telegram-ios/submodules/OpusBinding/SharedHeaders/libopus/include/opus
    find . -name "opus*.h" -exec cp {} submodules/telegram-ios/submodules/OpusBinding/SharedHeaders/libopus/include/opus/ \;

    # Fix Sparkle using BSD ln -sfh instead of GNU ln -sfn (coreutils)
    find submodules -name "project.pbxproj" -exec sed -i 's/ln -sfh/ln -sfn/g' {} + || true

    # Xcode's metal stub is broken even after `xcodebuild -downloadComponent MetalToolchain`.
    # Precompile with the working Shared Metal toolchain, then hide sources so xcodebuild
    # does not invoke CompileMetalFile.
    METAL=/Users/Shared/Metal.xctoolchain/usr/bin/metal
    METALLIB=/Users/Shared/Metal.xctoolchain/usr/bin/metallib

    $METAL -c -target air64-apple-macos10.13 \
      submodules/telegram-ios/submodules/MetalEngine/Sources/MetalEngineShaders.metal \
      -o MetalEngineShaders.air
    $METALLIB MetalEngineShaders.air -o MetalEngine.metallib

    $METAL -c -target air64-apple-macos10.13 -I packages/DustLayer/Sources \
      packages/DustLayer/Sources/DustEffectShaders.metal -o DustEffectShaders.air
    $METAL -c -target air64-apple-macos10.13 -I packages/DustLayer/Sources \
      packages/DustLayer/Sources/loki.metal -o loki.air
    $METAL -c -target air64-apple-macos10.13 -I packages/DustLayer/Sources \
      packages/DustLayer/Sources/loki_header.metal -o loki_header.air
    $METALLIB DustEffectShaders.air loki.air loki_header.air -o DustLayer.metallib

    if [ -f Telegram-Mac/MetalFunctions.metal ]; then
      $METAL -c -target air64-apple-macos10.13 Telegram-Mac/MetalFunctions.metal -o MetalFunctions.air
      $METALLIB MetalFunctions.air -o MetalFunctions.metallib
    fi

    # Hide metal sources so Xcode skips CompileMetalFile; keep copies as resources for Bundle.module
    find . -name "*.metal" -exec mv {} {}.txt \;
    find . -name "Package.swift" -exec sed -i 's/\.metal"/.metal.txt"/g' {} +
    sed -i '/MetalFunctions.metal in Sources/d' Telegram.xcodeproj/project.pbxproj || true

    # Xcode 26 rejects Firebase/Google SPM frameworks that use iOS-style shallow bundles on macOS.
    deepen_framework() {
      local fw="$1"
      local name
      name=$(basename "$fw" .framework)
      [ -d "$fw" ] || return 0
      [ -d "$fw/Versions" ] && return 0
      [ -f "$fw/Info.plist" ] || return 0

      mkdir -p "$fw/Versions/A/Resources"
      [ -f "$fw/$name" ] && mv "$fw/$name" "$fw/Versions/A/"
      [ -d "$fw/Headers" ] && mv "$fw/Headers" "$fw/Versions/A/"
      [ -d "$fw/Modules" ] && mv "$fw/Modules" "$fw/Versions/A/"
      if [ -d "$fw/Resources" ]; then
        # Merge existing Resources into Versions/A/Resources
        mv "$fw/Resources"/* "$fw/Versions/A/Resources/" 2>/dev/null || true
        rmdir "$fw/Resources" 2>/dev/null || rm -rf "$fw/Resources"
      fi
      [ -f "$fw/Info.plist" ] && mv "$fw/Info.plist" "$fw/Versions/A/Resources/"
      # Move any leftover top-level files into Versions/A
      for item in "$fw"/*; do
        base=$(basename "$item")
        case "$base" in
          Versions) ;;
          *) [ -e "$item" ] && mv "$item" "$fw/Versions/A/" ;;
        esac
      done
      ln -sfn A "$fw/Versions/Current"
      [ -e "$fw/Versions/Current/$name" ] && ln -sfn "Versions/Current/$name" "$fw/$name"
      [ -d "$fw/Versions/Current/Headers" ] && ln -sfn Versions/Current/Headers "$fw/Headers"
      [ -d "$fw/Versions/Current/Modules" ] && ln -sfn Versions/Current/Modules "$fw/Modules"
      ln -sfn Versions/Current/Resources "$fw/Resources"
    }

    deepen_embedded_frameworks() {
      local app="$1"
      local fw
      for fw in "$app"/Contents/Frameworks/*.framework; do
        deepen_framework "$fw"
      done
    }

    run_xcodebuild() {
      xcodebuild -workspace Telegram-Mac.xcworkspace \
                 -scheme Telegram \
                 -configuration Release \
                 -derivedDataPath build \
                 -clonedSourcePackagesDirPath build/swiftpm \
                 -IDEPackageSupportDisableManifestSandbox=YES \
                 -IDEPackageSupportDisablePluginExecutionSandbox=YES \
                 VALIDATE_PRODUCT=NO \
                 DISABLE_INFOPLIST_BUNDLE_VALIDATION=YES \
                 CODE_SIGN_IDENTITY="" \
                 CODE_SIGNING_REQUIRED=NO \
                 CODE_SIGNING_ALLOWED=NO
    }

    # First pass may fail at Validate on shallow Firebase frameworks.
    # Deepen them in-place and accept the app: re-running xcodebuild would
    # re-embed shallow copies from the XCFrameworks and fail again.
    set +e
    run_xcodebuild
    xcstatus=$?
    set -e
    if [ "$xcstatus" -ne 0 ]; then
      deepen_embedded_frameworks build/Build/Products/Release/Telegram.app
      if [ ! -d build/Build/Products/Release/Telegram.app/Contents/MacOS ]; then
        echo "xcodebuild failed before producing Telegram.app" >&2
        exit "$xcstatus"
      fi
      for fw in build/Build/Products/Release/Telegram.app/Contents/Frameworks/*.framework; do
        [ -d "$fw" ] || continue
        name=$(basename "$fw" .framework)
        case "$name" in
          FirebaseAnalytics|GoogleAppMeasurement|GoogleAppMeasurementIdentitySupport)
            if [ -f "$fw/Info.plist" ] || [ ! -f "$fw/Versions/Current/Resources/Info.plist" ]; then
              echo "failed to deepen $fw" >&2
              exit 1
            fi
            ;;
        esac
      done
    fi

    # Inject precompiled metallibs into SPM resource bundles / app
    metal_engine_bundle=$(find build/Build/Products/Release -type d -name 'MetalEngine_MetalEngine.bundle' | head -1)
    if [ -n "$metal_engine_bundle" ] && [ -f MetalEngine.metallib ]; then
      mkdir -p "$metal_engine_bundle/Contents/Resources"
      cp MetalEngine.metallib "$metal_engine_bundle/Contents/Resources/default.metallib"
    fi
    dust_bundle=$(find build/Build/Products/Release -type d -name 'DustLayer_DustLayer.bundle' | head -1)
    if [ -n "$dust_bundle" ] && [ -f DustLayer.metallib ]; then
      mkdir -p "$dust_bundle/Contents/Resources"
      cp DustLayer.metallib "$dust_bundle/Contents/Resources/default.metallib"
    fi
    if [ -f MetalFunctions.metallib ]; then
      mkdir -p build/Build/Products/Release/Telegram.app/Contents/Resources
      cp MetalFunctions.metallib build/Build/Products/Release/Telegram.app/Contents/Resources/default.metallib
    fi

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r build/Build/Products/Release/Telegram.app $out/Applications/

    runHook postInstall
  '';

  meta = {
    description = "Telegram for macOS (Native Swift Client)";
    longDescription = ''
      The native macOS Telegram client, built from source. 
      Warning: Building this requires Xcode and is generally not pure.
    '';
    homepage = "https://github.com/overtake/TelegramSwift";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.darwin;
  };
})
