{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchzip,
  rustPlatform,
  cargo,
  rustc,
  python3,
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
  writableTmpDirAsHomeHook,
}:

let
  version = "13.1.0-unstable-2026-10-30";
  rev = "7b3a0836dc8f5e68be862ad1315791f9ee743863";

  arch = stdenvNoCC.hostPlatform.darwinArch;
  rustTarget = stdenvNoCC.hostPlatform.rust.rustcTarget;
  # Upstream lipo steps expect a universal pair; only the host slice is built.
  foreignRustTarget = if arch == "arm64" then "x86_64-apple-darwin" else "aarch64-apple-darwin";

  # Xcode is supplied by the host, like nixpkgs' macvim. Keep the sandbox
  # enabled while preventing accidental dependencies on Homebrew in /usr/local.
  xcodeSandboxProfile = ''
    (allow file-read* file-write* process-exec mach-lookup)
    (deny file-read* file-write* process-exec mach-lookup (subpath "/usr/local") (with no-log))
    (allow file-read* process-exec (subpath "/var/run/com.apple.security.cryptexd"))
    (allow file-read* process-exec (subpath "/private/var/run/com.apple.security.cryptexd"))
    (allow file-read* (subpath "/System/Library/AssetsV2/com_apple_MobileAsset_MetalToolchain"))
  '';
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "telegram-mac";
  inherit version;

  src = fetchFromGitHub {
    owner = "TelegramMessenger";
    repo = "telegram-macos";
    inherit rev;
    hash = "sha256-svjbpIk0opy44A7/iPslOwhUZAPpE+ACXXe1V1le4L0=";
    # Unused private widget submodules are not part of the app's package graph.
    # Resolve the remaining submodules before fetchgit removes all Git metadata.
    postCheckout = ''
      cd "$out"
      git config submodule.third-party/twidget.update none
      git config submodule.third-party/widget-sandbox.update none
      export GIT_CONFIG_COUNT=2
      export GIT_CONFIG_KEY_0=url.https://github.com/.insteadOf
      export GIT_CONFIG_VALUE_0=git@github.com:
      export GIT_CONFIG_KEY_1=url.https://gitlab.com/.insteadOf
      export GIT_CONFIG_VALUE_1=git@gitlab.com:
      git submodule update --init --recursive --depth 1
    '';
  };

  ffmpegSrc = fetchzip {
    name = "ffmpeg-8.1.2-source";
    url = "https://ffmpeg.org/releases/ffmpeg-8.1.2.tar.xz";
    hash = "sha256-WEavSLtYdrKrYN5u+kUcWApDWHDLsaNxbOjwN9ma8TQ=";
  };

  openh264Src = fetchFromGitHub {
    owner = "cisco";
    repo = "openh264";
    tag = "v2.4.1";
    hash = "sha256-ai7lcGcQQqpsLGSwHkSs7YAoEfGCIbxdClO6JpGA+MI=";
  };

  opensslSrc = fetchFromGitHub {
    owner = "openssl";
    repo = "openssl";
    tag = "OpenSSL_1_1_1s";
    hash = "sha256-HPiUGzF9j9TS5nr0tqg01EZuN6upO1FblbbKmDp2GJo=";
  };

  # Vendor the union of the app libraries and the wallet binding generators.
  # Their independent lockfiles can resolve different versions of the same crate.
  cargoDeps = rustPlatform.fetchCargoVendor {
    name = "telegram-mac-${version}-deps";
    inherit (finalAttrs) src;
    nativeBuildInputs = [ python3 ];
    postPatch = ''
      python3 ${./files/merge-cargo-locks.py} \
        submodules/telegram-ios/third-party/wallet-engine/wallet-engine/Cargo.lock \
        submodules/telegram-ios/third-party/wallet-engine/wallet-engine/xtask/Cargo.lock \
        submodules/telegram-ios/third-party/wallet-engine/wallet-engine/bindgen/apple/Cargo.lock \
        submodules/telegram-ios/third-party/mtproto-engine/Cargo.lock \
        submodules/tlottie/Cargo.lock > Cargo.lock
    '';
    hash = "sha256-FUF46DDGzupd2W5V44kIzxdoRB7sjDGqgZeypiFonQ4=";
  };

  nativeBuildInputs = [
    cargo
    rustc
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

  sandboxProfile = xcodeSandboxProfile;
  dontUseCmakeConfigure = true;
  dontUseMesonConfigure = true;
  dontFixup = true; # Preserve the Xcode bundle layout and ad-hoc signatures.

  postPatch = ''
    # Nix manages updates; disable every entry point, including Settings.
    substituteInPlace Telegram-Mac/updater/AppUpdateViewController.swift \
      --replace-fail 'func updater_resetWithUpdaterSource(_ source: UpdaterSource, force: Bool = true) {' \
        'func updater_resetWithUpdaterSource(_ source: UpdaterSource, force: Bool = true) { return;'

    substituteInPlace core-xprojects/OpenH264/OpenH264/build.sh \
      --replace-fail 'git clone -b v2.4.1 https://github.com/cisco/openh264.git ''${BUILD_DIR}/openh264' \
        'cp -R "${finalAttrs.openh264Src}" "''${BUILD_DIR}/openh264" && chmod -R u+w "''${BUILD_DIR}/openh264"'
    substituteInPlace core-xprojects/openssl/OpenSSLEncryption/build.sh \
      --replace-fail 'git clone -b OpenSSL_1_1_1-stable https://github.com/openssl/openssl build/''${NAME}' \
        'cp -R "${finalAttrs.opensslSrc}" "build/''${NAME}" && chmod -R u+w "build/''${NAME}"'

    substituteInPlace core-xprojects/libopus/libopus/build.sh \
      --replace-fail 'cp -a $SOURCE_DIR/include/ $OUT_DIR/libopus/include/opus' \
        'cp -a $SOURCE_DIR/include/* $OUT_DIR/libopus/include/opus/'

    # These scripts expect BSD cp semantics (copy directory contents).
    substituteInPlace core-xprojects/webrtc/webrtc/build.sh \
      --replace-fail 'cp -R $SOURCE_DIR $BUILD_DIR' 'cp -R "$SOURCE_DIR"/. "$BUILD_DIR"/'
    substituteInPlace core-xprojects/Mozjpeg/Mozjpeg/build.sh \
      --replace-fail 'mozjpeg/" "''${BUILD_DIR}build/"' 'mozjpeg/"/. "''${BUILD_DIR}build/"'
    substituteInPlace core-xprojects/webrtc/webrtc.xcodeproj/project.pbxproj \
      --replace-fail 'libopus/build/libopus/include/opus' 'libopus/build/libopus/include/opus/include'

    # SwiftPM sandboxes manifest evaluation with sandbox-exec, which cannot
    # nest inside the build sandbox.
    substituteInPlace submodules/telegram-ios/submodules/TelegramApi/generate-swiftpm.sh \
      --replace-fail 'swift build -c release' 'swift build -c release --disable-sandbox'

    # Build Rust libraries for the Nix host platform rather than downloading a
    # second Rust standard library with rustup to produce universal binaries.
    for script in core-xprojects/{wallet-engine/wallet-engine,mtproto-engine/mtproto-engine,tlottie}/build.sh; do
      substituteInPlace "$script" \
        --replace-fail 'for RUST_TARGET in aarch64-apple-darwin x86_64-apple-darwin' 'for RUST_TARGET in ${rustTarget}'
      sed -i '\|"$BUILD_DIR/lib/${foreignRustTarget}/release/|d' "$script"
    done

    mkdir -p submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/ffmpeg-8.1.2
    cp -R ${finalAttrs.ffmpegSrc}/. submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/ffmpeg-8.1.2/
    install -m755 ${./files/ffmpeg-pkg-config} submodules/telegram-ios/submodules/ffmpeg/Sources/FFMpeg/pkg-config

    mkdir -p .cargo
    substitute ${finalAttrs.cargoDeps}/.cargo/config.toml .cargo/config.toml \
      --subst-var-by vendor ${finalAttrs.cargoDeps}

  '';

  buildPhase = ''
    runHook preBuild

    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export PATH="$PATH:$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    export CFFIXED_USER_HOME="$HOME"
    export CMAKE_POLICY_VERSION_MINIMUM=3.5
    export CARGO_NET_OFFLINE=true
    export CARGO_BUILD_JOBS="$NIX_BUILD_CORES"

    # Prefer BSD ln/tar; upstream scripts use ln -sfh and tar on ZIP archives.
    mkdir -p "$TMPDIR/macos-bin"
    ln -s /bin/ln /usr/bin/tar "$TMPDIR/macos-bin/"
    export PATH="$TMPDIR/macos-bin:$PATH"

    bash scripts/configure_frameworks.sh
    source ${./files/find-metal.sh}
    source ${./files/build-metal.sh}

    xcodebuild -workspace Telegram-Mac.xcworkspace \
      -scheme Telegram \
      -configuration Release \
      -derivedDataPath build \
      -disableAutomaticPackageResolution \
      -IDEPackageSupportDisableManifestSandbox=YES \
      -IDEPackageSupportDisablePluginExecutionSandbox=YES \
      ARCHS=${arch} ONLY_ACTIVE_ARCH=YES \
      CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO \
      'SWIFT_ACTIVE_COMPILATION_CONDITIONS=$(inherited) STABLE'

    install_metal_libraries build/Build/Products/Release

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -R build/Build/Products/Release/Telegram.app "$out/Applications/"
    /usr/bin/codesign --force --deep --sign - "$out/Applications/Telegram.app"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    app="$out/Applications/Telegram.app"
    test -x "$app/Contents/MacOS/Telegram"
    /usr/bin/plutil -lint "$app/Contents/Info.plist"
    /usr/bin/codesign --verify --deep --strict "$app"
    for name in MetalEngine_MetalEngine DustLayer_DustLayer CallVideoLayer_CallVideoLayer; do
      test -s "$app/Contents/Resources/$name.bundle/Contents/Resources/default.metallib"
    done

    runHook postInstallCheck
  '';

  meta = {
    description = "Native Telegram client for macOS";
    homepage = "https://macos.telegram.org/";
    changelog = "https://github.com/TelegramMessenger/telegram-macos/commits/${rev}";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    # Requires host Xcode and its separately installed Metal toolchain.
    hydraPlatforms = [ ];
  };
})
