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
  meson,
  fetchzip,
  writableTmpDirAsHomeHook,
}:

# Native Telegram for macOS (TelegramSwift) via host Xcode.
#
# Sandbox strategy (Darwin, matching nixpkgs macvim):
# - Keep the Nix sandbox ON (no __noChroot): network stays blocked.
# - Use a broad sandboxProfile so xcodebuild can use host Xcode / Metal.
# - Prefetch SwiftPM deps in a fixed-output derivation (FODs may use the network).
#
# Requires Xcode at /Applications/Xcode.app and the Metal toolchain
# (`xcodebuild -downloadComponent MetalToolchain`; `xcrun --find metal`).

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "telegram-mac";
  # Latest published GitHub source is the `release` branch tip (no Release tags).
  # Official DMGs may be newer; upstream MARKETING_VERSION here is 11.15.
  version = "11.15";

  ffmpegSrc = fetchzip {
    url = "https://ffmpeg.org/releases/ffmpeg-7.1.tar.xz";
    hash = "sha256-cNb7sIx7YIoVcamG6/cCFAdELSAm/N0OFBaJ1imJDQk=";
  };

  openh264Src = fetchzip {
    url = "https://github.com/cisco/openh264/archive/refs/tags/v2.4.1.tar.gz";
    hash = "sha256-ai7lcGcQQqpsLGSwHkSs7YAoEfGCIbxdClO6JpGA+MI=";
  };

  opensslSrc = fetchzip {
    url = "https://github.com/openssl/openssl/archive/refs/tags/OpenSSL_1_1_1s.tar.gz";
    hash = "sha256-HPiUGzF9j9TS5nr0tqg01EZuN6upO1FblbbKmDp2GJo=";
  };

  src = stdenvNoCC.mkDerivation {
    name = "telegram-mac-source";
    outputHashMode = "recursive";
    outputHash = "sha256-jBDhtqNNN0/m5C3fmtAmiLG0dAPMU5uf9yn0IkpfqRk=";

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
      git checkout 76ff8e4219452df317cd19e4df69b9e394dd5a87

      # The release branch pins private upstream remotes; use public mirrors that
      # contain the same commits (TelegramMessenger tag release-11.14 / overtake fork).
      substituteInPlace .gitmodules \
        --replace-fail 'git@gitlab.com:peter-iakovlev/telegram-ios.git' 'https://github.com/TelegramMessenger/Telegram-iOS.git' \
        --replace-fail 'git@github.com:john-preston/tgcalls.git' 'https://github.com/overtake/tgcalls.git'

      git submodule update --init --recursive
      rm -rf .git
    '';
  };

  # Fixed-output: may use the network. Produces Xcode's clonedSourcePackages tree.
  spmDeps = stdenvNoCC.mkDerivation {
    name = "telegram-mac-spm";
    outputHashMode = "recursive";
    outputHash = "sha256-gUhvx3B/16HIZ40Lda2pFhveKIKXERe1VmO9y42R0bc=";

    inherit (finalAttrs) src;
    nativeBuildInputs = [ writableTmpDirAsHomeHook ];

    # Host Xcode must be visible while resolving packages (same profile as the app build).
    sandboxProfile = ''
      (allow file-read* file-write* process-exec mach-lookup)
      (deny file-read* file-write* process-exec mach-lookup (subpath "/usr/local") (with no-log))
    '';

    buildCommand = ''
      export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
      export PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"
      export CFFIXED_USER_HOME=$HOME

      cp -a "$src" src
      chmod -R u+w src
      cd src

      mkdir -p "$out"
      # Local-package path quirks can make resolve exit non-zero after remotes are fetched.
      set +e
      xcodebuild -resolvePackageDependencies \
        -workspace Telegram-Mac.xcworkspace \
        -scheme Telegram \
        -clonedSourcePackagesDirPath "$out" \
        -derivedDataPath "$TMPDIR/derived" \
        -IDEPackageSupportDisableManifestSandbox=YES \
        -IDEPackageSupportDisablePluginExecutionSandbox=YES
      set -e

      test -d "$out/checkouts/firebase-ios-sdk"
      test -f "$out/workspace-state.json"

      substituteInPlace "$out/workspace-state.json" \
        --replace-fail "$out" '@SPM@' \
        --replace-fail "$NIX_BUILD_TOP/src" '@SRC@'

      # Drop checkout VCS dirs; keep repositories/ for Xcode's package graph.
      find "$out/checkouts" -name .git -print0 | xargs -0 rm -rf
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
    meson
    writableTmpDirAsHomeHook
  ];

  # Keep sandbox enabled (network blocked). Allow host Xcode like nixpkgs macvim.
  sandboxProfile = ''
    (allow file-read* file-write* process-exec mach-lookup)
    (deny file-read* file-write* process-exec mach-lookup (subpath "/usr/local") (with no-log))
    (allow file-read* process-exec (subpath "/var/run/com.apple.security.cryptexd"))
    (allow file-read* process-exec (subpath "/private/var/run/com.apple.security.cryptexd"))
    (allow file-read* (subpath "/System/Library/AssetsV2/com_apple_MobileAsset_MetalToolchain"))
  '';

  dontUseCmakeConfigure = true;
  dontUseMesonConfigure = true;

  buildPhase = ''
    runHook preBuild

    # Copy FFmpeg source
    mkdir -p submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/ffmpeg-7.1
    cp -r ${finalAttrs.ffmpegSrc}/* submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/ffmpeg-7.1/

    # Copy OpenH264 source to a safe place (Xcode might clean the build directory)
    mkdir -p core-xprojects/OpenH264/openh264_src
    cp -r ${finalAttrs.openh264Src}/* core-xprojects/OpenH264/openh264_src/

    # Copy OpenSSL source to a safe place
    mkdir -p core-xprojects/openssl_src
    cp -r ${finalAttrs.opensslSrc}/* core-xprojects/openssl_src/

    # Prefer macOS BSD ln/tar over Nix GNU tools (scripts use ln -sfh, tar-on-zip).
    # Keep GNU cp: BSD cp -a dir/ dest/ copies contents, while GNU nests as dest/dir/,
    # and libopus/webrtc include paths are tuned for the GNU layout.
    # Keep the rest of Nix PATH ahead of /usr/bin so gnused etc. stay available.
    mkdir -p "$TMPDIR/macos-bin"
    ln -sf /bin/ln /usr/bin/tar "$TMPDIR/macos-bin/"
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export PATH="$TMPDIR/macos-bin:$PATH:/usr/bin:/bin:/usr/sbin:/sbin"

    # CoreFoundation uses the user database for home dir, override it:
    export CFFIXED_USER_HOME=$HOME

    # Prefetched SwiftPM tree (relocatable placeholders -> this build tree).
    mkdir -p build/swiftpm
    cp -a ${finalAttrs.spmDeps}/. build/swiftpm/
    chmod -R u+w build/swiftpm
    substituteInPlace build/swiftpm/workspace-state.json \
      --replace-fail '@SPM@' "$PWD/build/swiftpm" \
      --replace-fail '@SRC@' "$PWD"

    # Telegram for macOS requires framework configuration first
    echo "yes" > scripts/rebuild

    # Fix CMake 3.5 compatibility for Mozjpeg
    substituteInPlace submodules/telegram-ios/third-party/mozjpeg/mozjpeg/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8.12)" "cmake_minimum_required(VERSION 3.5)"

    # Copy contents into existing build dirs (avoids nesting the source basename inside BUILD_DIR)
    substituteInPlace core-xprojects/webrtc/webrtc/build.sh \
      --replace-fail 'cp -R $SOURCE_DIR $BUILD_DIR' 'cp -R "$SOURCE_DIR"/. "$BUILD_DIR"/'

    substituteInPlace core-xprojects/Mozjpeg/Mozjpeg/build.sh \
      --replace-fail 'mozjpeg/" "''${BUILD_DIR}build/"' 'mozjpeg/"/. "''${BUILD_DIR}build/"'

    # Patch OpenH264 build script to use prefetched source instead of git clone
    substituteInPlace core-xprojects/OpenH264/OpenH264/build.sh \
      --replace-fail 'git clone -b v2.4.1 https://github.com/cisco/openh264.git ''${BUILD_DIR}/openh264' \
                     'cp -R "$(dirname "''${BUILD_DIR}")/openh264_src" "''${BUILD_DIR}/openh264" && chmod -R u+w "''${BUILD_DIR}/openh264"'

    # Patch OpenSSL build script to use prefetched source instead of git clone
    substituteInPlace core-xprojects/openssl/OpenSSLEncryption/build.sh \
      --replace-fail 'git clone -b OpenSSL_1_1_1-stable https://github.com/openssl/openssl build/''${NAME}' \
                     'cp -R ../openssl_src build/''${NAME} && chmod -R u+w build/''${NAME}'

    # GNU cp nests libopus headers at .../include/opus/include/; match that here.
    substituteInPlace core-xprojects/webrtc/webrtc.xcodeproj/project.pbxproj \
      --replace-fail 'libopus/build/libopus/include/opus' 'libopus/build/libopus/include/opus/include'

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
    find . -name "opus*.h" -exec cp {} submodules/telegram-ios/submodules/OpusBinding/SharedHeaders/libopus/include/opus/ \; || true

    # XcodeDefault's metal stub cannot compile. Xcode 26+ mounts MetalToolchain
    # under cryptexd; xcrun only finds it if ~/Library has the mapping plist, but
    # the Nix build HOME is a temp dir. Locate the toolchain on disk instead.
    METAL=
    METALLIB=
    for d in \
      /var/run/com.apple.security.cryptexd/mnt/com.apple.MobileAsset.MetalToolchain-*/Metal.xctoolchain \
      /private/var/run/com.apple.security.cryptexd/mnt/com.apple.MobileAsset.MetalToolchain-*/Metal.xctoolchain \
      /Users/Shared/Metal.xctoolchain \
      /Users/*/Library/Developer/DVTDownloads/MetalToolchain/mounts/*/Metal.xctoolchain
    do
      if [ -x "$d/usr/bin/metal" ] && [ -x "$d/usr/bin/metallib" ]; then
        METAL="$d/usr/bin/metal"
        METALLIB="$d/usr/bin/metallib"
        break
      fi
    done
    if [ -z "$METAL" ]; then
      METAL="$(xcrun --sdk macosx --find metal 2>/dev/null || true)"
      METALLIB="$(xcrun --sdk macosx --find metallib 2>/dev/null || true)"
      case "$METAL" in *XcodeDefault.xctoolchain*) METAL= ;; esac
      case "$METALLIB" in *XcodeDefault.xctoolchain*) METALLIB= ;; esac
    fi
    if [ ! -x "$METAL" ] || [ ! -x "$METALLIB" ]; then
      echo "Metal compiler not found (cryptexd mount, /Users/Shared/Metal.xctoolchain, xcrun)."
      echo "On the host run: xcodebuild -downloadComponent MetalToolchain && xcrun --find metal"
      exit 1
    fi
    echo "Using METAL=$METAL"
    echo "Using METALLIB=$METALLIB"

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

    # Hide metal sources so Xcode skips CompileMetalFile; keep copies as resources for Bundle.module.
    # substituteInPlace is a shell function — cannot use it with find -exec; use gnused instead.
    find . -name "*.metal" -exec mv {} {}.txt \;
    find . -name 'Package.swift' -exec sed -i 's/\.metal"/.metal.txt"/g' {} +
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
                 -disableAutomaticPackageResolution \
                 -onlyUsePackageVersionsFromResolvedFile \
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
      if [ ! -x build/Build/Products/Release/Telegram.app/Contents/MacOS/Telegram ]; then
        echo "xcodebuild failed before producing Telegram.app binary" >&2
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

    if [ ! -x build/Build/Products/Release/Telegram.app/Contents/MacOS/Telegram ]; then
      echo "Telegram.app binary missing after build" >&2
      exit 1
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
      Native macOS Telegram client built from source with host Xcode.
      Darwin builds use a macvim-style sandboxProfile (sandbox stays on;
      SwiftPM deps are prefetched as a fixed-output derivation).
    '';
    homepage = "https://github.com/overtake/TelegramSwift";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.darwin;
    # Host Xcode + Metal toolchain (xcrun metal); not buildable on Hydra.
    hydraPlatforms = [ ];
  };
})
