{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  jq,
  writableTmpDirAsHomeHook,
}:

let
  xcodeSandboxProfile = ''
    (allow file-read* file-write* process-exec mach-lookup)
    (deny file-read* file-write* process-exec mach-lookup (subpath "/usr/local") (with no-log))
  '';
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "compositor";
  version = "1.4.5";

  src = fetchFromGitHub {
    owner = "robbietilton";
    repo = "Compositor";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VwGIy0eam0UfBCj+d58mzHYYaXLD07sb41eLLrOX2c4=";
  };

  passthru.spmDeps = stdenvNoCC.mkDerivation {
    name = "compositor-spm-${finalAttrs.version}";
    outputHashMode = "recursive";
    outputHash = "sha256-9eSSVS8/4caRbXZzMopicFPeFodsCAPliAA4h7vxXgY=";

    inherit (finalAttrs) src;

    nativeBuildInputs = [
      jq
      writableTmpDirAsHomeHook
    ];

    sandboxProfile = xcodeSandboxProfile;

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
      set +e
      env PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH" \
      xcodebuild -resolvePackageDependencies \
        -scheme Compositor \
        -clonedSourcePackagesDirPath "$out" \
        -derivedDataPath "$TMPDIR/derived" \
        -IDEPackageSupportDisableManifestSandbox=YES \
        -IDEPackageSupportDisablePluginExecutionSandbox=YES
      set -e

      rm -rf "$out/repositories"
      find "$out" -name .git -print0 | xargs -0 rm -rf
      find "$out" -type d -name xcuserdata -print0 | xargs -0 rm -rf
      substituteInPlace "$out/workspace-state.json" \
        --replace-fail "$out" '@SPM@'
    '';
  };

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
  ];

  sandboxProfile = xcodeSandboxProfile;

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

    env PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH" \
    xcodebuild -project Compositor.xcodeproj \
               -scheme Compositor \
               -configuration Release \
               -derivedDataPath build \
               -clonedSourcePackagesDirPath build/swiftpm \
               -disableAutomaticPackageResolution \
               -onlyUsePackageVersionsFromResolvedFile \
               -IDEPackageSupportDisableManifestSandbox=YES \
               -IDEPackageSupportDisablePluginExecutionSandbox=YES \
               CODE_SIGN_IDENTITY="-" \
               MODULE_VERIFIER_SUPPORTED_LANGUAGES="" \
               MODULE_VERIFIER_SUPPORTED_LANGUAGE_STANDARDS="" \
               OTHER_SWIFT_FLAGS="-Xfrontend -disable-sandbox"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -R build/Build/Products/Release/Compositor.app $out/Applications/

    runHook postInstall
  '';

  meta = with lib; {
    description = "The Photoshop alternative for Mac";
    homepage = "https://github.com/robbietilton/Compositor";
    license = licenses.mit;
    platforms = platforms.darwin;
  };
})
