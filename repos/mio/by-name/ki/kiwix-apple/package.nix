{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  xcodegen,
  python3,
  makeBinaryWrapper,
  nix-update-script,
}:

# nixpkgs' kiwix-apple only unpacks the release DMG. This builds the macOS app
# from the upstream Xcode project instead: xcodegen generates the project and
# CoreKiwix comes from the libkiwix xcframework upstream links against.
#
# Upstream's project.yml pulls the SwiftPM dependencies from GitHub. Since the
# build sandbox has no network, the pinned sources are fetched separately and
# the generated project references them as local packages.
let
  libkiwixVersion = "14.2.1-2";

  libkiwix = fetchurl {
    url = "https://download.kiwix.org/release/libkiwix/libkiwix_xcframework-${libkiwixVersion}.tar.gz";
    hash = "sha256-FIIGSHiN3cPfion/CCCvYNfvwc/abINgKYlFUmPuFWE=";
  };

  defaults = fetchFromGitHub {
    owner = "sindresorhus";
    repo = "Defaults";
    tag = "v8.2.0";
    hash = "sha256-irrCnZhXnjWySFuga/eFDoR2/aLfuyS6hkb2e6XDQxo=";
  };

  stripeApplePay = fetchFromGitHub {
    owner = "CodeLikeW";
    repo = "stripe-apple-pay";
    tag = "25.7.2";
    hash = "sha256-ZnNGLw4XsHZ+f5bDDHi1xfF+3mwrll3ZxUtSQySvU7U=";
  };

  stripeCore = fetchFromGitHub {
    owner = "CodeLikeW";
    repo = "stripe-core";
    tag = "25.7.2";
    hash = "sha256-UoTkymvosSo61KTWQjA9qGN7WQkX2CauRpawfzshn6s=";
  };

  swiftSystem = fetchFromGitHub {
    owner = "apple";
    repo = "swift-system";
    rev = "b083113aef646d9d35403ca17e9789b750e42d1d";
    hash = "sha256-wEWL0CFGy8PKv0PDULDraH3/PBhe232hZb6t6prnlPw=";
  };
in
stdenvNoCC.mkDerivation (
  finalAttrs:
  {
    pname = "kiwix-apple";
    version = "3.19.0";

    src = fetchFromGitHub {
      owner = "kiwix";
      repo = "kiwix-apple";
      tag = finalAttrs.version;
      hash = "sha256-tMK2W4yn3rH1e/G/K3zOhQoe9KGqrktWvfFJAelxvnI=";
    };

    strictDeps = true;

    nativeBuildInputs = [
      xcodegen
      python3
      makeBinaryWrapper
    ];

    postPatch = ''
      # SwiftPM derives a local package's identity from its directory name, so
      # keep the names the dependency declarations expect.
      mkdir -p deps
      cp -R ${defaults} deps/Defaults
      cp -R ${stripeApplePay} deps/stripe-apple-pay
      cp -R ${stripeCore} deps/stripe-core
      cp -R ${swiftSystem} deps/swift-system
      chmod -R u+w deps

      # stripe-apple-pay pulls stripe-core from GitHub; point it at the copy we
      # fetched instead.
      substituteInPlace deps/stripe-apple-pay/Package.swift \
        --replace-fail \
          '.package(url: "https://github.com/CodeLikeW/stripe-core", from: "25.7.2")' \
          ".package(path: \"$PWD/deps/stripe-core\")"

      # Replace the remote package references with local checkouts.
      ${python3}/bin/python3 - <<'PY'
      import re
      from pathlib import Path

      spec = Path("project.yml")
      text = spec.read_text()
      deps = Path.cwd() / "deps"
      packages = f"""packages:
        Defaults:
          path: {deps / 'Defaults'}
        StripeApplePay:
          path: {deps / 'stripe-apple-pay'}
        SwiftSystem:
          path: {deps / 'swift-system'}
      """
      text = re.sub(r"^packages:\n(?:[ ]+.*\n)*", packages, text, count=1, flags=re.MULTILINE)
      spec.write_text(text)
      PY
    '';

    buildPhase = ''
      runHook preBuild

      export USER=kiwix
      export PATH=/usr/bin:$PATH
      export HOME=$PWD/home TMPDIR=$PWD/tmp
      # Foundation resolves the home directory from the account database, which
      # points at /var/empty inside a Nix build; CFFIXED_USER_HOME overrides it.
      export CFFIXED_USER_HOME=$HOME
      mkdir -p "$HOME" "$TMPDIR"

      tar xzf ${libkiwix} --strip-components 2
      for triplet in ios-arm64 ios-arm64_x86_64-simulator macos-arm64_x86_64; do
        cp Support/CoreKiwix.modulemap "CoreKiwix.xcframework/$triplet/Headers/module.modulemap"
      done
      ${python3}/bin/python3 localizations.py generate
      xcodegen

      xcodebuild \
        -workspace Kiwix.xcodeproj/project.xcworkspace \
        -scheme Kiwix \
        -configuration Release \
        -destination 'generic/platform=macOS' \
        -archivePath "$PWD/Kiwix.xcarchive" \
        -derivedDataPath "$PWD/DerivedData" \
        -disableAutomaticPackageResolution \
        -IDEPackageSupportDisableManifestSandbox=1 \
        -IDEPackageSupportDisablePluginExecutionSandbox=1 \
        OTHER_SWIFT_FLAGS='$(inherited) -disable-sandbox' \
        XBS_DISABLE_SANDBOXED_BUILDS=1 \
        SWIFTPM_SANDBOX=0 \
        CODE_SIGNING_ALLOWED=NO \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGN_IDENTITY="" \
        archive

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/Applications" "$out/bin"
      cp -R Kiwix.xcarchive/Products/Applications/Kiwix.app "$out/Applications/"
      makeBinaryWrapper "$out/Applications/Kiwix.app/Contents/MacOS/Kiwix" "$out/bin/${finalAttrs.meta.mainProgram}"

      runHook postInstall
    '';

    dontFixup = true;

    passthru.updateScript = nix-update-script {
      extraArgs = [
        "--url=https://github.com/kiwix/kiwix-apple"
        "--version-regex=(.*\\..*\\..*)"
      ];
    };

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      test -x "$out/Applications/Kiwix.app/Contents/MacOS/Kiwix"
      test -x "$out/bin/${finalAttrs.meta.mainProgram}"
      runHook postInstallCheck
    '';

    meta = {
      description = "Offline reader for Web content";
      downloadPage = "https://get.kiwix.org/en/solutions/applications/kiwix-reader/";
      homepage = "https://get.kiwix.org/en/solutions/applications/";
      license = lib.licenses.gpl3Plus;
      mainProgram = "kiwix";
      platforms = lib.platforms.darwin;
      sourceProvenance = with lib.sourceTypes; [
        fromSource
        binaryNativeCode # CoreKiwix xcframework
      ];
    };
  }
  // lib.optionalAttrs stdenvNoCC.hostPlatform.isDarwin {
    # Xcode lives outside the Nix store, and the darwin sandbox only exposes a
    # fixed set of system paths; the build needs the real xcodebuild.
    __noChroot = true;
  }
)
