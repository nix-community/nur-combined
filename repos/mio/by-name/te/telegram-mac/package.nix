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

# Native Telegram for macOS (overtake/TelegramSwift) via host Xcode.
#
# Upstream publishes no GitHub Releases. The newest *source* is the `release`
# branch (MARKETING_VERSION 11.15, 2025-07-31). `master` is older (11.14.1).
# macos.telegram.org ships 12.x binaries; that tree is not on GitHub
# (see overtake/TelegramSwift#1404).
#
# Sandbox stays on (no __noChroot). SwiftPM deps are a FOD. Host needs
# /Applications/Xcode.app and MetalToolchain (`xcodebuild -downloadComponent MetalToolchain`).

let
  # Broad enough for xcodebuild; deny /usr/local like nixpkgs macvim.
  xcodeSandboxProfile = ''
    (allow file-read* file-write* process-exec mach-lookup)
    (deny file-read* file-write* process-exec mach-lookup (subpath "/usr/local") (with no-log))
  '';

  metalSandboxProfile = xcodeSandboxProfile + ''
    (allow file-read* process-exec (subpath "/var/run/com.apple.security.cryptexd"))
    (allow file-read* process-exec (subpath "/private/var/run/com.apple.security.cryptexd"))
    (allow file-read* (subpath "/System/Library/AssetsV2/com_apple_MobileAsset_MetalToolchain"))
  '';
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "telegram-mac";
  version = "11.15";

  # `release` tip; no tags. Bump src.outputHash + spmDeps.outputHash together.
  srcRev = "76ff8e4219452df317cd19e4df69b9e394dd5a87";

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
    name = "telegram-mac-source-${finalAttrs.version}";
    outputHashMode = "recursive";
    outputHash = "sha256-jBDhtqNNN0/m5C3fmtAmiLG0dAPMU5uf9yn0IkpfqRk=";

    inherit (finalAttrs) srcRev;
    nativeBuildInputs = [
      git
      cacert
      writableTmpDirAsHomeHook
    ];

    buildCommand = ''
      git config --global url."https://github.com/".insteadOf "git@github.com:"
      git config --global url."https://gitlab.com/".insteadOf "git@gitlab.com:"

      git clone https://github.com/overtake/TelegramSwift.git "$out"
      cd "$out"
      git checkout "$srcRev"

      # Private remotes in .gitmodules; public mirrors have the same commits.
      substituteInPlace .gitmodules \
        --replace-fail 'git@gitlab.com:peter-iakovlev/telegram-ios.git' 'https://github.com/TelegramMessenger/Telegram-iOS.git' \
        --replace-fail 'git@github.com:john-preston/tgcalls.git' 'https://github.com/overtake/tgcalls.git'

      git submodule update --init --recursive
      rm -rf .git
    '';
  };

  spmDeps = stdenvNoCC.mkDerivation {
    name = "telegram-mac-spm-${finalAttrs.version}";
    outputHashMode = "recursive";
    outputHash = "sha256-dgtVtu5i0CBA0PQ3IuWqPQaQTdTbPjXe/5S02h9qoGA=";

    inherit (finalAttrs) src;
    nativeBuildInputs = [ writableTmpDirAsHomeHook ];
    sandboxProfile = xcodeSandboxProfile;

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

  sandboxProfile = metalSandboxProfile;

  dontUseCmakeConfigure = true;
  dontUseMesonConfigure = true;

  buildPhase = ''
    runHook preBuild

    mkdir -p submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/ffmpeg-7.1
    cp -r ${finalAttrs.ffmpegSrc}/* submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/ffmpeg-7.1/

    mkdir -p core-xprojects/OpenH264/openh264_src
    cp -r ${finalAttrs.openh264Src}/* core-xprojects/OpenH264/openh264_src/

    mkdir -p core-xprojects/openssl_src
    cp -r ${finalAttrs.opensslSrc}/* core-xprojects/openssl_src/

    # Prefer macOS BSD ln/tar over Nix GNU tools (scripts use ln -sfh, tar-on-zip).
    # Keep GNU cp: BSD cp -a dir/ dest/ copies contents, while GNU nests as dest/dir/,
    # and libopus/webrtc include paths are tuned for the GNU layout.
    mkdir -p "$TMPDIR/macos-bin"
    ln -sf /bin/ln /usr/bin/tar "$TMPDIR/macos-bin/"
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export PATH="$TMPDIR/macos-bin:$PATH:/usr/bin:/bin:/usr/sbin:/sbin"
    export CFFIXED_USER_HOME=$HOME

    mkdir -p build/swiftpm
    cp -a ${finalAttrs.spmDeps}/. build/swiftpm/
    chmod -R u+w build/swiftpm
    substituteInPlace build/swiftpm/workspace-state.json \
      --replace-fail '@SPM@' "$PWD/build/swiftpm" \
      --replace-fail '@SRC@' "$PWD"

    echo "yes" > scripts/rebuild

    substituteInPlace submodules/telegram-ios/third-party/mozjpeg/mozjpeg/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8.12)" "cmake_minimum_required(VERSION 3.5)"

    substituteInPlace core-xprojects/webrtc/webrtc/build.sh \
      --replace-fail 'cp -R $SOURCE_DIR $BUILD_DIR' 'cp -R "$SOURCE_DIR"/. "$BUILD_DIR"/'

    substituteInPlace core-xprojects/Mozjpeg/Mozjpeg/build.sh \
      --replace-fail 'mozjpeg/" "''${BUILD_DIR}build/"' 'mozjpeg/"/. "''${BUILD_DIR}build/"'

    substituteInPlace core-xprojects/OpenH264/OpenH264/build.sh \
      --replace-fail 'git clone -b v2.4.1 https://github.com/cisco/openh264.git ''${BUILD_DIR}/openh264' \
                     'cp -R "$(dirname "''${BUILD_DIR}")/openh264_src" "''${BUILD_DIR}/openh264" && chmod -R u+w "''${BUILD_DIR}/openh264"'

    substituteInPlace core-xprojects/openssl/OpenSSLEncryption/build.sh \
      --replace-fail 'git clone -b OpenSSL_1_1_1-stable https://github.com/openssl/openssl build/''${NAME}' \
                     'cp -R ../openssl_src build/''${NAME} && chmod -R u+w build/''${NAME}'

    substituteInPlace core-xprojects/webrtc/webrtc.xcodeproj/project.pbxproj \
      --replace-fail 'libopus/build/libopus/include/opus' 'libopus/build/libopus/include/opus/include'

    install -m755 ${./files/ffmpeg-pkg-config} \
      submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/pkg-config

    sh scripts/configure_frameworks.sh

    mkdir -p submodules/telegram-ios/submodules/OpusBinding/SharedHeaders/libopus/include/opus
    find . -name "opus*.h" -exec cp {} submodules/telegram-ios/submodules/OpusBinding/SharedHeaders/libopus/include/opus/ \; || true

    source ${./files/find-metal.sh}

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
    find . -name "*.metal" -exec mv {} {}.txt \;
    find . -name 'Package.swift' -exec sed -i 's/\.metal"/.metal.txt"/g' {} +
    sed -i '/MetalFunctions.metal in Sources/d' Telegram.xcodeproj/project.pbxproj || true

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
        mv "$fw/Resources"/* "$fw/Versions/A/Resources/" 2>/dev/null || true
        rmdir "$fw/Resources" 2>/dev/null || rm -rf "$fw/Resources"
      fi
      [ -f "$fw/Info.plist" ] && mv "$fw/Info.plist" "$fw/Versions/A/Resources/"
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
    # Deepen them in-place; re-running xcodebuild would re-embed shallow copies.
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

  passthru = {
    inherit (finalAttrs) srcRev;
  };

  meta = {
    description = "Telegram for macOS (native Swift client)";
    longDescription = ''
      Built from the latest published TelegramSwift `release` source (11.15).
      Official 12.x DMGs are not reproducible from GitHub. Darwin builds keep
      the Nix sandbox on (macvim-style sandboxProfile); SwiftPM is prefetched.
    '';
    homepage = "https://github.com/overtake/TelegramSwift";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    hydraPlatforms = [ ];
  };
})
