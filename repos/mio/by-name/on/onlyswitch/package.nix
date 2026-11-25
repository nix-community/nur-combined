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
  # Host Xcode, same approach as launchy/compositor; see
  # shared/xcode-sandbox.nix. The widget and app icon need the Metal toolchain.
  xcodeSandbox = import ../../../shared/xcode-sandbox.nix;

  arch = stdenvNoCC.hostPlatform.darwinArch;
  sparkleVersion = "2.10.0";

  sparkleSrc = fetchzip {
    pname = "sparkle";
    version = sparkleVersion;
    url = "https://github.com/sparkle-project/Sparkle/archive/refs/tags/${sparkleVersion}.tar.gz";
    hash = "sha256-8AWJAue55l+sie0hQ+isH/LYxd9fxBKbGAq15gxn6Dg=";
  };

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

  # OnlySwitch's manifest uses Sparkle as an SPM binary target. Build the
  # framework from the tagged Sparkle source and expose it as a local package
  # instead of accepting the prebuilt xcframework from the release archive.
  sparkle = stdenvNoCC.mkDerivation {
    pname = "sparkle";
    version = sparkleVersion;

    src = sparkleSrc;

    patches = [ ./sparkle-remove-cli-package.patch ];

    nativeBuildInputs = [ writableTmpDirAsHomeHook ];

    sandboxProfile = xcodeSandbox.withMetalToolchain;

    dontFixup = true;

    buildPhase = ''
      runHook preBuild

      export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
      export CFFIXED_USER_HOME=$HOME
      # Host clang/swift must not inherit Nix's purity flags.
      unset NIX_ENFORCE_PURITY NIX_CFLAGS_COMPILE NIX_LDFLAGS NIX_CC NIX_CXX LD CC CXX OBJC OBJCXX

      export PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin''${PATH:+:$PATH}"

      /usr/bin/xcodebuild -quiet \
        -project Sparkle.xcodeproj \
        -target Sparkle \
        -configuration Release \
        SYMROOT="$PWD/build" \
        OBJROOT="$PWD/obj" \
        ARCHS=${arch} \
        ONLY_ACTIVE_ARCH=NO \
        CODE_SIGNING_ALLOWED=NO \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGN_IDENTITY="" \
        ENABLE_USER_SCRIPT_SANDBOXING=NO \
        -disableAutomaticPackageResolution \
        build

      rm -rf Sparkle.xcframework
      /usr/bin/xcodebuild -create-xcframework \
        -framework "$PWD/build/Release/Sparkle.framework" \
        -output "$PWD/Sparkle.xcframework"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -a Sparkle.xcframework "$out/"

      runHook postInstall
    '';
  };

  prepareSource = ''
    mkdir -p Modules/Vendor/Sparkle
    cp ${sparklePackageSwift} Modules/Vendor/Sparkle/Package.swift
    cp -a ${sparkle}/Sparkle.xcframework Modules/Vendor/Sparkle/

    ${python3}/bin/python3 - <<'PY'
    import re
    from pathlib import Path

    root = Path(".")

    manifest = root / "Modules/Package.swift"
    text = manifest.read_text()
    text, count = re.subn(
        r'\.package\(url: "https://github\.com/sparkle-project/Sparkle", (?:exact|from): "[^"]+"\)',
        '.package(path: "Vendor/Sparkle")',
        text,
        count=1,
    )
    if count != 1:
        raise SystemExit("error: Sparkle dependency not found in Modules/Package.swift")
    manifest.write_text(text)

    project = root / "OnlySwitch.xcodeproj/project.xcproj"
    text = project.read_text()
    text, count = re.subn(
        r'\n    \}, \{\n      "kind": "remote",\n      "repository": "https://github\.com/sparkle-project/Sparkle",\n      "version": \{\n        "version": "[^"]+",\n      \},\n    \}, \{',
        '\n    }, {',
        text,
        count=1,
    )
    if count != 1:
        raise SystemExit("error: Sparkle package not found in project.xcproj")
    project.write_text(text)

    for name in [
        "Modules/Package.resolved",
        "OnlySwitch.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved",
    ]:
        path = root / name
        text = path.read_text()
        text, count = re.subn(
            r'\n    \{\n      "identity" : "sparkle",\n      "kind" : "remoteSourceControl",\n      "location" : "https://github\.com/sparkle-project/Sparkle",\n      "state" : \{\n        "revision" : "[^"]+",\n        "version" : "[^"]+"\n      \}\n    \},\n',
            '\n',
            text,
            count=1,
        )
        if count != 1:
            raise SystemExit(f"error: Sparkle pin not found in {name}")
        path.write_text(text)
    PY
  '';
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "onlyswitch";
  version = "3.7.0";

  src = fetchFromGitHub {
    owner = "jacklandrin";
    repo = "OnlySwitch";
    rev = "release_${finalAttrs.version}";
    hash = "sha256-9FjUbIlmk+kHwuK0ImQi5wfiPZxEmjSwz2TEM9GL5zE=";
  };

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
    python3
  ];

  sandboxProfile = xcodeSandbox.withMetalToolchain;

  # Preserve the app bundle, widget, helper, and Sparkle framework layout.
  dontFixup = true;

  postPatch = prepareSource;

  passthru = {
    inherit sparkleVersion;

    # Resolve OnlySwitch's SwiftPM graph once with network access, then reuse
    # the checkouts and binary artifacts in the sandboxed app build.
    spmDeps = stdenvNoCC.mkDerivation {
      pname = "${finalAttrs.pname}-spm-deps";
      inherit (finalAttrs) version src;

      outputHashMode = "recursive";
      outputHash = "sha256-Sa98WlVGUXtQp3n/ilwfGQBrIpJdm0rN/8MTslvi7/g=";

      nativeBuildInputs = [
        writableTmpDirAsHomeHook
        python3
      ];

      sandboxProfile = xcodeSandbox.withMetalToolchain;

      buildCommand = ''
        export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
        export CFFIXED_USER_HOME=$HOME
        export GIT_CONFIG_COUNT=1
        export GIT_CONFIG_KEY_0=core.autocrlf
        export GIT_CONFIG_VALUE_0=false

        cp -a "$src" src
        chmod -R u+w src
        cd src

        ${prepareSource}

        mkdir -p "$out"
        env PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH" \
        xcodebuild -resolvePackageDependencies \
          -project OnlySwitch.xcodeproj \
          -scheme OnlySwitch \
          -clonedSourcePackagesDirPath "$out" \
          -derivedDataPath "$TMPDIR/derived" \
          -IDEPackageSupportDisableManifestSandbox=YES \
          -IDEPackageSupportDisablePluginExecutionSandbox=YES

        rm -rf "$out/repositories"
        find "$out" -name .git -print0 | xargs -0 rm -rf
        find "$out" -type d -name xcuserdata -print0 | xargs -0 rm -rf

        # SwiftPM does not keep artifact order stable between resolutions.
        # Sort the arrays before hashing so spmDeps and its updater are
        # reproducible.
        ${python3}/bin/python3 - <<'PY'
        import json
        import os
        from pathlib import Path

        path = Path(os.environ["out"]) / "workspace-state.json"
        data = json.loads(path.read_text())
        object_data = data["object"]
        object_data["artifacts"].sort(
            key=lambda item: (
                item.get("packageRef", {}).get("identity", ""),
                item.get("targetName", ""),
                item.get("path", ""),
            )
        )
        object_data["dependencies"].sort(
            key=lambda item: (
                item.get("packageRef", {}).get("identity", ""),
                item.get("packageRef", {}).get("location", ""),
            )
        )
        if isinstance(object_data.get("prebuilts"), list):
            object_data["prebuilts"].sort(key=lambda item: json.dumps(item, sort_keys=True))
        path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
        PY

        substituteInPlace "$out/workspace-state.json" \
          --replace-fail "$PWD" '@SRC@'
        substituteInPlace "$out/workspace-state.json" \
          --replace-fail "$out" '@SPM@'
      '';
    };

    updateScript = writeShellApplication {
      name = "update-onlyswitch";
      runtimeInputs = [
        python3
        nix
        nix-update
        git
        cacert
      ];
      text = ''
        export UPDATE_NIX_ATTR_PATH="onlyswitch"
        export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
        exec ${python3}/bin/python3 ${./update.py} "$@"
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
      --replace-fail '@SRC@' "$PWD" \
      --replace-fail '@SPM@' "$PWD/build/swiftpm"

    env PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH" \
      xcodebuild \
        -project OnlySwitch.xcodeproj \
        -scheme OnlySwitch \
        -configuration Release \
        -destination "platform=macOS,arch=${arch}" \
        -derivedDataPath build \
        -clonedSourcePackagesDirPath build/swiftpm \
        -disableAutomaticPackageResolution \
        -onlyUsePackageVersionsFromResolvedFile \
        -skipMacroValidation \
        -skipPackagePluginValidation \
        -IDEPackageSupportDisableManifestSandbox=YES \
        -IDEPackageSupportDisablePluginExecutionSandbox=YES \
        CODE_SIGNING_ALLOWED=NO \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGN_IDENTITY="" \
        DEVELOPMENT_TEAM="" \
        PROVISIONING_PROFILE_SPECIFIER="" \
        ARCHS=${arch} \
        ONLY_ACTIVE_ARCH=YES \
        ENABLE_USER_SCRIPT_SANDBOXING=NO \
        'OTHER_SWIFT_FLAGS=$(inherited) -Xfrontend -disable-sandbox' \
        build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -a build/Build/Products/Release/OnlySwitch.app "$out/Applications/"
    ln -s "$out/Applications/OnlySwitch.app/Contents/MacOS/OnlySwitch" "$out/bin/onlyswitch"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    app="$out/Applications/OnlySwitch.app"
    test -x "$app/Contents/MacOS/OnlySwitch"
    test -x "$app/Contents/MacOS/OnlySwitchPrivilegedHelper"
    test -d "$app/Contents/PlugIns/OnlyWidgetExtension.appex"
    test -d "$app/Contents/Frameworks/Sparkle.framework"
    test -f "$app/Contents/Library/LaunchDaemons/com.jacklandrin.OnlySwitch.PrivilegedHelper.plist"
    /usr/bin/plutil -lint "$app/Contents/Info.plist"

    runHook postInstallCheck
  '';

  meta = {
    description = "Menu bar utility with macOS switches and widgets";
    homepage = "https://github.com/jacklandrin/OnlySwitch";
    downloadPage = "https://github.com/jacklandrin/OnlySwitch/releases";
    changelog = "https://github.com/jacklandrin/OnlySwitch/releases/tag/release_${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    mainProgram = "onlyswitch";
    # Building needs the host Xcode, which no Nix builder provides.
    hydraPlatforms = [ ];
  };
})
