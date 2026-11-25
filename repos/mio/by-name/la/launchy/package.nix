{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchzip,
  writableTmpDirAsHomeHook,
  writeShellApplication,
  python3,
  nix,
  nix-update,
  git,
  cacert,
}:

let
  # Host Xcode, same approach as compositor/telegram-mac; see
  # shared/xcode-sandbox.nix. Upstream builds its app icon with Icon Composer,
  # so the Metal toolchain has to be reachable.
  xcodeSandbox = import ../../../shared/xcode-sandbox.nix;

  sparkleVersion = "2.10.1";

  sparklePackageSwift = builtins.toFile "Package.swift" ''
    // swift-tools-version:5.5
    import PackageDescription

    let package = Package(
        name: "Sparkle",
        platforms: [.macOS(.v12)],
        products: [
            .library(name: "Sparkle", targets: ["Sparkle"])
        ],
        targets: [
            .binaryTarget(name: "Sparkle", path: "Sparkle.xcframework")
        ]
    )
  '';
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "launchy";
  version = "2026.9.0";

  src = fetchFromGitHub {
    owner = "Punshnut";
    repo = "macos-launchy";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Vd9bfgP4EsMMOBPVI9jq6aXl3ixyWIFIC1JSNnteY40=";
  };

  # Sparkle ships an SPM binary target, but its Xcode project can build the
  # framework from the tagged source. That keeps Launchy's provenance
  # fromSource and avoids vendoring Sparkle's prebuilt framework.
  sparkle = fetchzip {
    pname = "sparkle";
    version = sparkleVersion;
    url = "https://github.com/sparkle-project/Sparkle/archive/refs/tags/${sparkleVersion}.tar.gz";
    hash = "sha256-U9sFD/aPaCi4zw38vlVMV2CVp2X8BppKCaJSZKmkj1M=";
  };

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];

  sandboxProfile = xcodeSandbox.withMetalToolchain;

  # Preserve the app-bundle layout and any ad-hoc codesign from the toolchain.
  dontFixup = true;

  postPatch = ''
    mkdir -p Vendor/Sparkle .sparkle-src
    cp -a ${finalAttrs.sparkle}/. .sparkle-src/
    chmod -R u+w .sparkle-src

    # swift-argument-parser is only used by Sparkle's command-line tools. Drop
    # that package graph so the framework target builds without network access.
    patch -p1 -d .sparkle-src < ${./sparkle-remove-cli-package.patch}

    cp ${sparklePackageSwift} Vendor/Sparkle/Package.swift

    substituteInPlace Package.swift \
      --replace-fail \
        '.package(url: "https://github.com/sparkle-project/Sparkle.git", from: "2.6.0")' \
        '.package(path: "Vendor/Sparkle")'

    # SPM's nested sandbox-exec cannot run inside the Nix build sandbox.
    substituteInPlace scripts/build_app.sh \
      --replace-fail \
        'swift build -c release --triple' \
        'swift build -c release --disable-sandbox --triple'

    # Upstream tag v2026.9.0 still shipped Info.plist as 2026.8; align the
    # marketing version with the release. Nix owns updates, so disable Sparkle.
    /usr/bin/plutil -replace CFBundleShortVersionString -string ${lib.versions.majorMinor finalAttrs.version} Resources/Info.plist
    /usr/bin/plutil -replace SUEnableAutomaticChecks -bool false Resources/Info.plist
    /usr/bin/plutil -replace SUAutomaticallyUpdate -bool false Resources/Info.plist
  '';

  buildPhase = ''
    runHook preBuild

    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    export CFFIXED_USER_HOME=$HOME
    # Host clang/swift must not inherit Nix's purity flags.
    unset NIX_ENFORCE_PURITY NIX_CFLAGS_COMPILE NIX_LDFLAGS NIX_CC NIX_CXX LD CC CXX OBJC OBJCXX

    export PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin''${PATH:+:$PATH}"
    export ARCHES=${stdenvNoCC.hostPlatform.darwinArch}
    export SPARKLE_FRAMEWORK_SRC="$PWD/Vendor/Sparkle/Sparkle.xcframework/macos-arm64_x86_64/Sparkle.framework"

    sparkle_build="$PWD/build/sparkle"
    mkdir -p "$sparkle_build"
    /usr/bin/xcodebuild -quiet \
      -project "$PWD/.sparkle-src/Sparkle.xcodeproj" \
      -target Sparkle \
      -configuration Release \
      SYMROOT="$sparkle_build/build" \
      OBJROOT="$sparkle_build/obj" \
      ARCHS="arm64 x86_64" \
      ONLY_ACTIVE_ARCH=NO \
      -disableAutomaticPackageResolution \
      build
    /usr/bin/xcodebuild -create-xcframework \
      -framework "$sparkle_build/build/Release/Sparkle.framework" \
      -output "$PWD/Vendor/Sparkle/Sparkle.xcframework"

    ./scripts/build_app.sh

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -R Launchy.app "$out/Applications/"
    ln -s "$out/Applications/Launchy.app/Contents/MacOS/Launchy" "$out/bin/launchy"

    runHook postInstall
  '';

  passthru = {
    inherit sparkleVersion;
    updateScript = writeShellApplication {
      name = "update-launchy";
      runtimeInputs = [
        python3
        nix
        nix-update
        git
        cacert
      ];
      text = ''
        export UPDATE_NIX_ATTR_PATH="launchy"
        export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
        exec ${python3}/bin/python3 ${./update.py} "$@"
      '';
    };
  };

  meta = {
    description = "Open-source Launchpad alternative for macOS";
    homepage = "https://github.com/Punshnut/macos-launchy";
    downloadPage = "https://github.com/Punshnut/macos-launchy/releases";
    changelog = "https://github.com/Punshnut/macos-launchy/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "launchy";
  };
})
