{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
  writeShellApplication,
  nix-update-script,
}:

let
  # The app is built by the host's Xcode; see shared/xcode-sandbox.nix.
  xcodeSandbox = import ../../../shared/xcode-sandbox.nix;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "compositor";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "robbietilton";
    repo = "Compositor";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7HwlxJFbO3g6oGGx8b6S7U9syMRdUcNc0K+3LAX2G20=";
  };

  # Two expressions upstream's Xcode accepts are rejected by Xcode 26's
  # type checker; see the patch header for the explicit-type fixes.
  patches = [ ./xcode-26-type-check-fixes.patch ];

  postPatch = ''
    substituteInPlace Compositor/Document/CameraRawShadows.swift \
      --replace-fail \
        'return (0..<count).map { i in (lower?[i] ?? 0) * (1 - t) + (upper?[i] ?? 0) * t }' \
        'return (0..<count).map { i -> Float in let l: Float = lower?[i] ?? 0; let u: Float = upper?[i] ?? 0; return l * (1 - t) + u * t }'
  '';

  passthru = {
    spmDeps = stdenvNoCC.mkDerivation {
      pname = "${finalAttrs.pname}-spm-deps";
      inherit (finalAttrs) version src;

      outputHashMode = "recursive";
      outputHash = "sha256-9eSSVS8/4caRbXZzMopicFPeFodsCAPliAA4h7vxXgY=";

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
          -scheme Compositor \
          -clonedSourcePackagesDirPath "$out" \
          -derivedDataPath "$TMPDIR/derived" \
          -IDEPackageSupportDisableManifestSandbox=YES \
          -IDEPackageSupportDisablePluginExecutionSandbox=YES

        rm -rf "$out/repositories"
        find "$out" -name .git -print0 | xargs -0 rm -rf
        find "$out" -type d -name xcuserdata -print0 | xargs -0 rm -rf
        substituteInPlace "$out/workspace-state.json" \
          --replace-fail "$out" '@SPM@'
      '';
    };

    updateScript = writeShellApplication {
      name = "update-compositor";
      text = ''
        export UPDATE_NIX_ATTR_PATH="compositor"
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

  sandboxProfile = xcodeSandbox.base;

  # The bundle is ad-hoc signed by Xcode (CODE_SIGN_IDENTITY below), and fixup
  # would strip the binaries and rewrite load commands, invalidating that
  # signature; the app keeps the layout Xcode produced.
  dontFixup = true;

  buildPhase = ''
    runHook preBuild

    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export CFFIXED_USER_HOME=$HOME

    # Unset Nix variables that might interfere with Xcode's compiler/linker invocations
    unset NIX_ENFORCE_PURITY NIX_CFLAGS_COMPILE NIX_LDFLAGS NIX_CC NIX_CXX LD CC CXX OBJC OBJCXX

    mkdir -p build/swiftpm
    cp -a ${finalAttrs.passthru.spmDeps}/. build/swiftpm/
    chmod -R u+w build/swiftpm
    substituteInPlace build/swiftpm/workspace-state.json \
      --replace-fail '@SPM@' "$PWD/build/swiftpm"

    # A plain assignment: `local` is only valid inside a function, and stdenv
    # runs the phase under `set -e`.
    xcodebuildFlags=(
      -project Compositor.xcodeproj
      -scheme Compositor
      -configuration Release
      -derivedDataPath build
      -clonedSourcePackagesDirPath build/swiftpm
      -disableAutomaticPackageResolution
      -onlyUsePackageVersionsFromResolvedFile
      -IDEPackageSupportDisableManifestSandbox=YES
      -IDEPackageSupportDisablePluginExecutionSandbox=YES
      CODE_SIGN_IDENTITY="-"
      MODULE_VERIFIER_SUPPORTED_LANGUAGES=""
      MODULE_VERIFIER_SUPPORTED_LANGUAGE_STANDARDS=""
      OTHER_SWIFT_FLAGS="-Xfrontend -disable-sandbox"
    )

    env PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH" \
      xcodebuild "''${xcodebuildFlags[@]}"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications $out/bin
    cp -R build/Build/Products/Release/Compositor.app $out/Applications/

    # Symlink the executable into bin/ for CLI access
    ln -s $out/Applications/Compositor.app/Contents/MacOS/Compositor $out/bin/Compositor

    runHook postInstall
  '';

  meta = {
    description = "The Photoshop alternative for Mac";
    homepage = "https://github.com/robbietilton/Compositor";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    mainProgram = "Compositor";
  };
})
