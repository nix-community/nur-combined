{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
  writeShellApplication,
  nix-update-script,
}:

let
  # Builds against the host's Xcode, like nixpkgs' macvim; see
  # shared/xcode-sandbox.nix.
  xcodeSandbox = import ../../../shared/xcode-sandbox.nix;

  arch = stdenvNoCC.hostPlatform.darwinArch;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "purge";
  version = "1.18.1";

  src = fetchFromGitHub {
    owner = "jithin-sabu";
    repo = "purge-app";
    rev = "v${finalAttrs.version}";
    hash = "sha256-6POZ0Hkdgriu1cOnfGIlmIkFquw5hseu1UkcsbbCZ7w=";
  };

  # Xcode 26.3's type checker times out on one long row-count sum; the patch
  # binds each term to an Int. See the patch header.
  patches = [ ./xcode-26.3-type-check-fixes.patch ];

  # Nix owns updates. Sparkle's automatic background checks would otherwise
  # replace the store copy of the app with the upstream release.
  postPatch = ''
    /usr/bin/plutil -replace SUEnableAutomaticChecks -bool false purge/Info.plist
    /usr/bin/plutil -replace SUAutomaticallyUpdate -bool false purge/Info.plist
  '';

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];

  sandboxProfile = xcodeSandbox.base;

  # Preserve the app-bundle layout of the helper tools.
  dontFixup = true;

  passthru = {
    # Sparkle is a SwiftPM binary target, so the package resolution has to
    # download the release xcframework once. This fetches it into a store path
    # the sandboxed build can reuse offline.
    spmDeps = stdenvNoCC.mkDerivation {
      pname = "${finalAttrs.pname}-spm-deps";
      inherit (finalAttrs) version src;

      outputHashMode = "recursive";
      outputHash = "sha256-4ZfpPc509dmJmCQ8MRV37/CfypYlcM2+BYEvBJ87Uhw=";

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
          -project purge.xcodeproj \
          -scheme purge \
          -clonedSourcePackagesDirPath "$out" \
          -derivedDataPath "$TMPDIR/derived" \
          -IDEPackageSupportDisableManifestSandbox=YES \
          -IDEPackageSupportDisablePluginExecutionSandbox=YES

        # Only the resolved checkouts and the Sparkle xcframework are needed.
        rm -rf "$out/repositories"
        find "$out" -name .git -print0 | xargs -0 rm -rf
        find "$out" -type d -name xcuserdata -print0 | xargs -0 rm -rf
        substituteInPlace "$out/workspace-state.json" \
          --replace-fail "$out" '@SPM@'
      '';
    };

    updateScript = writeShellApplication {
      name = "update-purge";
      text = ''
        export UPDATE_NIX_ATTR_PATH="purge"
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

  buildPhase = ''
    runHook preBuild

    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export CFFIXED_USER_HOME=$HOME
    # Host clang/swift must not inherit Nix's purity flags.
    unset NIX_ENFORCE_PURITY NIX_CFLAGS_COMPILE NIX_LDFLAGS NIX_CC NIX_CXX LD CC CXX OBJC OBJCXX

    mkdir -p build/swiftpm
    cp -a ${finalAttrs.passthru.spmDeps}/. build/swiftpm/
    chmod -R u+w build/swiftpm
    substituteInPlace build/swiftpm/workspace-state.json \
      --replace-fail '@SPM@' "$PWD/build/swiftpm"

    # Xcode turns on code coverage for this scheme by default; a release build
    # should not carry the profiling runtime.
    env PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH" \
      xcodebuild \
        -project purge.xcodeproj \
        -scheme purge \
        -configuration Release \
        -derivedDataPath build \
        -clonedSourcePackagesDirPath build/swiftpm \
        -disableAutomaticPackageResolution \
        -onlyUsePackageVersionsFromResolvedFile \
        -IDEPackageSupportDisableManifestSandbox=YES \
        -IDEPackageSupportDisablePluginExecutionSandbox=YES \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        ARCHS=${arch} \
        ONLY_ACTIVE_ARCH=YES \
        ENABLE_USER_SCRIPT_SANDBOXING=NO \
        ENABLE_CODE_COVERAGE=NO \
        CLANG_COVERAGE_MAPPING=NO \
        CLANG_ENABLE_CODE_COVERAGE=NO \
        'OTHER_SWIFT_FLAGS=$(inherited) -Xfrontend -disable-sandbox'

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications $out/bin
    cp -R build/Build/Products/Release/Purge.app $out/Applications/
    ln -s $out/Applications/Purge.app/Contents/MacOS/Purge $out/bin/purge

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    app="$out/Applications/Purge.app"
    test -x "$app/Contents/MacOS/Purge"
    test -x "$app/Contents/MacOS/io.getpurge.helper"
    test -x "$app/Contents/MacOS/io.getpurge.assetworker"
    test -x "$app/Contents/MacOS/io.getpurge.watch"
    test -f "$app/Contents/Library/LaunchDaemons/io.getpurge.helper.plist"
    test -f "$app/Contents/Library/LaunchAgents/io.getpurge.watch.plist"
    test -d "$app/Contents/Frameworks/Sparkle.framework"
    test -f "$app/Contents/Resources/brand-icon-manifest.json"
    /usr/bin/plutil -lint "$app/Contents/Info.plist"

    runHook postInstallCheck
  '';

  meta = {
    description = "Free up your Mac safely by clearing app caches and leftover files";
    homepage = "https://github.com/jithin-sabu/purge-app";
    downloadPage = "https://github.com/jithin-sabu/purge-app/releases";
    changelog = "https://github.com/jithin-sabu/purge-app/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode # Sparkle.xcframework is a SwiftPM binary target
    ];
    mainProgram = "purge";
    # Building needs the host Xcode, which no Nix builder provides.
    hydraPlatforms = [ ];
  };
})
