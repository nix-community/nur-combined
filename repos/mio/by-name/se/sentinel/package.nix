{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
  writeShellApplication,
  nix-update-script,
}:

let
  # Builds against the host's Xcode, like compositor/launchnext; see
  # shared/xcode-sandbox.nix.
  xcodeSandbox = import ../../../shared/xcode-sandbox.nix;

  arch = stdenvNoCC.hostPlatform.darwinArch;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sentinel";
  version = "3.1.4";

  src = fetchFromGitHub {
    owner = "alienator88";
    repo = "Sentinel";
    tag = finalAttrs.version;
    hash = "sha256-8c05LbXwfH8XwaUw0Ax/LQs7Orsp0z0zsRxmrcJCh9Y=";
  };

  passthru = {
    # Upstream pins AlinFoundation to a branch but records its revision in
    # Package.resolved. Cache that resolved graph so the build stays offline.
    spmDeps = stdenvNoCC.mkDerivation {
      pname = "${finalAttrs.pname}-spm-deps";
      inherit (finalAttrs) version src;

      outputHashMode = "recursive";
      outputHash = "sha256-jA8liKHVyw26wXJvGduhYPiGXDIMcQGHDM+o1fSeuBo=";

      nativeBuildInputs = [ writableTmpDirAsHomeHook ];

      sandboxProfile = xcodeSandbox.base;

      buildCommand = ''
        export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
        export CFFIXED_USER_HOME=$HOME
        export GIT_CONFIG_COUNT=1
        export GIT_CONFIG_KEY_0=core.autocrlf
        export GIT_CONFIG_VALUE_0=false

        cp -a "$src" src
        chmod -R u+w src
        cd src

        mkdir -p "$out"
        env PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH" \
          xcodebuild -resolvePackageDependencies \
            -scheme "Sentinel - Release" \
            -clonedSourcePackagesDirPath "$out" \
            -derivedDataPath "$TMPDIR/derived" \
            -IDEPackageSupportDisableManifestSandbox=YES \
            -IDEPackageSupportDisablePluginExecutionSandbox=YES

        rm -rf "$out/repositories"
        find "$out" -name .git -print0 | xargs -0 rm -rf
        find "$out" -type d -name xcuserdata -print0 | xargs -0 rm -rf

        # Xcode 26.3 can leave an empty marker at the cache root while writing
        # the real workspace state under DerivedData in the Nix build sandbox.
        if ! test -s "$out/workspace-state.json"; then
          state=$(find "$TMPDIR/derived" -name workspace-state.json -size +0c -print -quit)
          test -n "$state"
          cp "$state" "$out/workspace-state.json"
        fi
      '';
    };

    updateScript = writeShellApplication {
      name = "update-sentinel";
      text = ''
        export UPDATE_NIX_ATTR_PATH="sentinel"
        exec ${
          lib.escapeShellArgs (nix-update-script {
            extraArgs = [
              "--subpackage"
              "spmDeps"
            ];
          })
        } "$@"
      '';
    };
  };

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];

  sandboxProfile = xcodeSandbox.withMetalToolchain;

  # The app and its Finder extension are ad-hoc signed after Xcode builds them.
  # Nix fixup would rewrite Mach-O files and invalidate those signatures.
  dontFixup = true;

  buildPhase = ''
    runHook preBuild

    ${xcodeSandbox.env}

    mkdir -p build/swiftpm
    cp -a ${finalAttrs.passthru.spmDeps}/. build/swiftpm/
    chmod -R u+w build/swiftpm

    env PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH" \
      xcodebuild \
      -project Sentinel.xcodeproj \
      -scheme "Sentinel - Release" \
      -configuration Release \
      -derivedDataPath build \
      -clonedSourcePackagesDirPath build/swiftpm \
      -destination "platform=macOS,arch=${arch}" \
      -disableAutomaticPackageResolution \
      -onlyUsePackageVersionsFromResolvedFile \
      -skipPackagePluginValidation \
      -skipMacroValidation \
      -IDEPackageSupportDisableManifestSandbox=YES \
      -IDEPackageSupportDisablePluginExecutionSandbox=YES \
      CODE_SIGNING_ALLOWED=NO \
      CODE_SIGNING_REQUIRED=NO \
      CODE_SIGN_IDENTITY="" \
      CODE_SIGN_STYLE=Manual \
      DEVELOPMENT_TEAM="" \
      PROVISIONING_PROFILE_SPECIFIER="" \
      ENABLE_HARDENED_RUNTIME=YES \
      MARKETING_VERSION=${finalAttrs.version} \
      ARCHS=${arch} \
      ONLY_ACTIVE_ARCH=YES \
      'OTHER_SWIFT_FLAGS=$(inherited) -Xfrontend -disable-sandbox' \
      build

    app="$PWD/build/Build/Products/Release/Sentinel.app"
    /usr/bin/codesign --force --timestamp=none --sign - --options runtime \
      --entitlements "$PWD/FinderOpen/FinderOpen.entitlements" \
      "$app/Contents/PlugIns/FinderOpen.appex"
    /usr/bin/codesign --force --timestamp=none --sign - --options runtime \
      --entitlements "$PWD/Sentinel/SentinelApp.entitlements" \
      "$app"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -R build/Build/Products/Release/Sentinel.app "$out/Applications/"
    ln -s "$out/Applications/Sentinel.app/Contents/MacOS/Sentinel" "$out/bin/sentinel"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    app="$out/Applications/Sentinel.app"
    test -x "$app/Contents/MacOS/Sentinel"
    test -x "$app/Contents/PlugIns/FinderOpen.appex/Contents/MacOS/FinderOpen"
    test "$(/usr/bin/plutil -extract CFBundleShortVersionString raw "$app/Contents/Info.plist")" = "${finalAttrs.version}"
    /usr/bin/plutil -lint "$app/Contents/Info.plist"
    /usr/bin/codesign --verify --deep --strict "$app"

    runHook postInstallCheck
  '';

  meta = {
    description = "GUI for controlling Gatekeeper, unquarantining and signing macOS apps";
    homepage = "https://github.com/alienator88/Sentinel";
    downloadPage = "https://github.com/alienator88/Sentinel/releases";
    changelog = "https://github.com/alienator88/Sentinel/releases/tag/${finalAttrs.version}";
    # Apache-2.0 with the Commons Clause, which makes the combined work nonfree.
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "sentinel";
    # Building needs the host Xcode, which no Nix builder provides.
    hydraPlatforms = [ ];
  };
})
