{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchzip,
  writableTmpDirAsHomeHook,
  nix-update-script,
}:

let
  # Host Xcode, same approach as compositor/telegram-mac: keep the Nix
  # sandbox but block accidental Homebrew deps under /usr/local.
  xcodeSandboxProfile = ''
    (allow file-read* file-write* process-exec mach-lookup)
    (deny file-read* file-write* process-exec mach-lookup (subpath "/usr/local") (with no-log))
    (allow file-read* process-exec (subpath "/var/run/com.apple.security.cryptexd"))
    (allow file-read* process-exec (subpath "/private/var/run/com.apple.security.cryptexd"))
    (allow file-read* (subpath "/System/Library/AssetsV2/com_apple_MobileAsset_MetalToolchain"))
  '';

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

  # Sparkle ships as an SPM binary target. Vendor the release zip as a path
  # dependency so `scripts/build_app.sh` can run fully offline.
  sparkle = fetchzip {
    pname = "sparkle-spm";
    version = sparkleVersion;
    url = "https://github.com/sparkle-project/Sparkle/releases/download/${sparkleVersion}/Sparkle-for-Swift-Package-Manager.zip";
    hash = "sha256-yMw24NHBebnIuCaQ2iRESWqwFnG2nYBO4RpKWxqmXpQ=";
    stripRoot = false;
  };

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];

  sandboxProfile = xcodeSandboxProfile;

  # Preserve the app-bundle layout and any ad-hoc codesign from the toolchain.
  dontFixup = true;

  postPatch = ''
    mkdir -p Vendor/Sparkle
    cp -a ${finalAttrs.sparkle}/. Vendor/Sparkle/
    chmod -R u+w Vendor/Sparkle
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
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open-source Launchpad alternative for macOS";
    homepage = "https://github.com/Punshnut/macos-launchy";
    downloadPage = "https://github.com/Punshnut/macos-launchy/releases";
    changelog = "https://github.com/Punshnut/macos-launchy/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode # vendored Sparkle.framework
    ];
    mainProgram = "launchy";
  };
})
