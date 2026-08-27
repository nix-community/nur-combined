{
  lib,
  stdenvNoCC,
  python3,
  git,
  cacert,
  jq,
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
  fetchpatch,
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
    url = "https://ffmpeg.org/releases/ffmpeg-7.1.1.tar.xz";
    hash = "sha256-PMAtwm8oKm9tnX6x4Fj5vd+VBDoafEYKB83eKgLlClg=";
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
    outputHash = "sha256-GqpLd0prXqipJiVekTbyE6KnRkdhi4UHiScAp3EwU2U=";

    inherit (finalAttrs) srcRev;
    nativeBuildInputs = [
      git
      cacert
      writableTmpDirAsHomeHook
    ];

    buildCommand = ''
      # Keep checkout metadata out of the FOD (and stable across machines).
      export GIT_CONFIG_COUNT=3
      export GIT_CONFIG_KEY_0=url.https://github.com/.insteadof
      export GIT_CONFIG_VALUE_0=git@github.com:
      export GIT_CONFIG_KEY_1=url.https://gitlab.com/.insteadof
      export GIT_CONFIG_VALUE_1=git@gitlab.com:
      export GIT_CONFIG_KEY_2=core.autocrlf
      export GIT_CONFIG_VALUE_2=false

      git clone https://github.com/overtake/TelegramSwift.git "$out"
      cd "$out"
      git checkout "$srcRev"

      # Private remotes in .gitmodules; public mirrors have the same commits.
      substituteInPlace .gitmodules \
        --replace-fail 'git@gitlab.com:peter-iakovlev/telegram-ios.git' 'https://github.com/TelegramMessenger/Telegram-iOS.git' \
        --replace-fail 'git@github.com:john-preston/tgcalls.git' 'https://github.com/overtake/tgcalls.git'

      git submodule update --init --recursive

      # Top-level rm is not enough: nested submodule .git files/dirs remain and
      # can differ across git versions / clone layouts.
      find "$out" -name .git -print0 | xargs -0 rm -rf
      find "$out" -type d -name xcuserdata -print0 | xargs -0 rm -rf
    '';
  };

  patches = [
    # overtake/TelegramSwift#1371 — Xcode 26 / CMake 3.5 / ffmpeg 7.1.1
    (fetchpatch {
      name = "telegram-mac-pr1371-xcode26-cmake-ffmpeg.patch";
      url = "https://github.com/overtake/TelegramSwift/compare/579cebbf0c01fd41b712eff3647fa7f69db9665d...56ae13e0ab0ddf5120aa40bb6f5d327ea70af75a.patch";
      hash = "sha256-5scfRe7vYGnCXaGAnU04gtykb9fodBbVFSmkJzK9MOA=";
      excludes = [ "INSTALL.md" ];
    })
    # #1416 macOS hook skipped: Telegram-iOS#4 is macos-11.14-release and cannot
    # replace the 11.15 telegram-ios pin (StarGift/search APIs break). The hook
    # alone would refresh unsupported media without the new TL parsers.
    # (fetchpatch {
    #   name = "telegram-mac-pr1416-refresh-unsupported-rich-bot-messages.patch";
    #   url = "https://github.com/overtake/TelegramSwift/commit/335d53699c06a5bce83aaabd9604ccd378479422.patch";
    #   hash = "sha256-IsLpLrW3NnwCZr/s4SIFYliTL1ga47HxUJFOs0f2UIo=";
    #   excludes = [ "submodules/telegram-ios" ];
    # })
    # overtake/TelegramSwift#1446 — clamp attributed-string link ranges
    (fetchpatch {
      name = "telegram-mac-pr1446-clamp-attributed-string-link-range.patch";
      url = "https://github.com/overtake/TelegramSwift/commit/a80ae5a9e497832ace2975f9430bd986f1ca54e7.patch";
      hash = "sha256-6YgLrw4FCDdTB3vJcoGc90AujMwq+HXbGpGtDXkRtCw=";
    })
  ];

  spmDeps = stdenvNoCC.mkDerivation {
    name = "telegram-mac-spm-${finalAttrs.version}";
    outputHashMode = "recursive";
    # Drop bare `repositories/` mirrors after resolve; full-ref packs were the
    # cross-machine hash churn (`fetch = +refs/*` tracks remote tip noise).
    outputHash = "sha256-N7G40yy9dvM3SaMvjGK+kx91SWK3iKyiaKcn3Z1zywg=";

    inherit (finalAttrs) src;
    nativeBuildInputs = [
      jq
      writableTmpDirAsHomeHook
    ];
    sandboxProfile = xcodeSandboxProfile;

    buildCommand = ''
      export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
      export PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"
      export CFFIXED_USER_HOME=$HOME
      export GIT_CONFIG_COUNT=1
      export GIT_CONFIG_KEY_0=core.autocrlf
      export GIT_CONFIG_VALUE_0=false

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

      # Bare mirrors are not needed for -disableAutomaticPackageResolution builds
      # and are the main cross-machine hash instability (full-ref packs).
      rm -rf "$out/repositories"

      find "$out/checkouts" -name .git -print0 | xargs -0 rm -rf
      find "$out" -type d -name xcuserdata -print0 | xargs -0 rm -rf

      substituteInPlace "$out/workspace-state.json" \
        --replace-fail "$out" '@SPM@' \
        --replace-fail "$NIX_BUILD_TOP/src" '@SRC@'

      # Stable serialization across xcodebuild pretty-printers.
      jq -cS . "$out/workspace-state.json" > "$TMPDIR/workspace-state.json"
      mv "$TMPDIR/workspace-state.json" "$out/workspace-state.json"
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

    mkdir -p submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/ffmpeg-7.1.1 \
             submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/ffmpeg-7.1
    cp -r ${finalAttrs.ffmpegSrc}/* submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/ffmpeg-7.1.1/
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

    # Disable built-in updater (updates are managed by Nix)
    substituteInPlace Telegram-Mac/AppDelegate.swift \
      --replace-fail 'updater_resetWithUpdaterSource' '// updater_resetWithUpdaterSource' \
      --replace-fail 'showModal(with: InputDataModalController(AppUpdateViewController()), for: window)' '// showModal(with: InputDataModalController(AppUpdateViewController()), for: window)'

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
                 CODE_SIGNING_ALLOWED=NO \
                 MODULE_VERIFIER_SUPPORTED_LANGUAGES="" \
                 MODULE_VERIFIER_SUPPORTED_LANGUAGE_STANDARDS=""
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
