{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
  writeShellApplication,
  nix-update-script,
}:

let
  # Builds against the host's Xcode, like launchy/purge; see
  # shared/xcode-sandbox.nix.
  xcodeSandbox = import ../../../shared/xcode-sandbox.nix;

  arch = stdenvNoCC.hostPlatform.darwinArch;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "launchnext";
  version = "2.4.2";

  src = fetchFromGitHub {
    owner = "RoversX";
    repo = "LaunchNext";
    rev = finalAttrs.version;
    hash = "sha256-rM7SFSQqOgGzd19PrL7RviIqmdif9L7+CRNW5ELidfU=";
  };

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];

  sandboxProfile = xcodeSandbox.base;

  # Preserve the app-bundle layout (including the bundled SwiftUpdater) and its
  # ad-hoc signature from the toolchain.
  dontFixup = true;

  buildPhase = ''
    runHook preBuild

    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export CFFIXED_USER_HOME=$HOME
    # Host clang/swift must not inherit Nix's purity flags.
    unset NIX_ENFORCE_PURITY NIX_CFLAGS_COMPILE NIX_LDFLAGS NIX_CC NIX_CXX LD CC CXX OBJC OBJCXX

    export PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin''${PATH:+:$PATH}"

    # Xcode attaches the system Metal toolchain disk image inside $HOME to
    # compile the Icon Composer app icon. Left attached, it keeps Nix from
    # deleting the build directory, so detach it on exit (also on failure).
    detach_metal_toolchain() {
      for mountpoint in "$HOME"/Library/Developer/DVTDownloads/MetalToolchain/mounts/*; do
        [ -d "$mountpoint" ] || continue
        /usr/bin/hdiutil detach -quiet "$mountpoint" || true
      done
    }
    trap detach_metal_toolchain EXIT

    # Xcode's "Run Script (Updater)" phase only copies an existing binary and
    # fails the build when it is missing, so build SwiftUpdater first.
    swift build \
      --package-path UpdaterScripts/SwiftUpdater \
      --configuration release \
      --product SwiftUpdater \
      --disable-sandbox \
      -j "$NIX_BUILD_CORES"

    xcodebuild \
      -project LaunchNext.xcodeproj \
      -scheme LaunchNext \
      -configuration Release \
      -derivedDataPath build \
      -destination "platform=macOS,arch=${arch}" \
      -skipPackagePluginValidation \
      -skipMacroValidation \
      -IDEPackageSupportDisableManifestSandbox=YES \
      -IDEPackageSupportDisablePluginExecutionSandbox=YES \
      CODE_SIGN_STYLE=Manual \
      CODE_SIGN_IDENTITY="-" \
      DEVELOPMENT_TEAM="" \
      PROVISIONING_PROFILE_SPECIFIER="" \
      ENABLE_HARDENED_RUNTIME=YES \
      ENABLE_USER_SCRIPT_SANDBOXING=NO \
      MARKETING_VERSION=${finalAttrs.version} \
      ARCHS=${arch} \
      ONLY_ACTIVE_ARCH=YES \
      'OTHER_SWIFT_FLAGS=$(inherited) -Xfrontend -disable-sandbox' \
      build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -R build/Build/Products/Release/LaunchNext.app "$out/Applications/"
    ln -s "$out/Applications/LaunchNext.app/Contents/MacOS/LaunchNext" "$out/bin/launchnext"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    app="$out/Applications/LaunchNext.app"
    test -x "$app/Contents/MacOS/LaunchNext"
    test -x "$app/Contents/Resources/Updater/SwiftUpdater"
    test "$(/usr/bin/plutil -extract CFBundleShortVersionString raw "$app/Contents/Info.plist")" = "${finalAttrs.version}"
    /usr/bin/plutil -lint "$app/Contents/Info.plist"
    /usr/bin/codesign --verify "$app/Contents/Resources/Updater/SwiftUpdater"

    runHook postInstallCheck
  '';

  passthru = {
    updateScript = writeShellApplication {
      name = "update-launchnext";
      text = ''
        export UPDATE_NIX_ATTR_PATH="launchnext"
        exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
      '';
    };
  };

  meta = {
    description = "Launchpad alternative for macOS 26+ with folders, fuzzy search and layout import";
    homepage = "https://github.com/RoversX/LaunchNext";
    downloadPage = "https://github.com/RoversX/LaunchNext/releases";
    changelog = "https://github.com/RoversX/LaunchNext/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "launchnext";
    # Building needs the host Xcode, which no Nix builder provides.
    hydraPlatforms = [ ];
  };
})
