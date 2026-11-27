{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  unzip,
  writableTmpDirAsHomeHook,
  writeShellApplication,
  python3,
  nix,
  nix-update,
  git,
  cacert,
}:

# UTM cannot be compiled without a sysroot of prebuilt native dependencies
# (QEMU, SPICE, GStreamer, ...) staged at the repository root. Upstream builds
# that sysroot in CI and publishes it as the `Sysroot-macos-universal` artifact
# of the tag's build run; downloading an artifact needs a GitHub login, so it is
# fetched through nightly.link, which mirrors public artifacts. The artifact
# expires 90 days after the run, so re-run the update script to move to a newer
# run before then.
#
# 5.0.6 and later import the macOS 27 SDK frameworks AccessoryAccess and
# DiskImageKit, so they need Xcode 26.4 or newer. 5.0.5 is the newest release
# that builds with the macOS 26 SDK that current Xcode ships.
let
  # Host Xcode; see shared/xcode-sandbox.nix. The bundled CocoaSpice renderer
  # compiles a Metal shader, which needs the separately downloaded Metal
  # toolchain.
  xcodeSandbox = import ../../../shared/xcode-sandbox.nix;

  # Build run of the v5.0.5 tag, also used by update.py to move the sysroot.
  sysrootRun = "33593908499";

  sysroot = fetchurl {
    name = "utm-sysroot-macOS.zip";
    url = "https://nightly.link/utmapp/UTM/actions/runs/${sysrootRun}/Sysroot-macos-universal.zip";
    hash = "sha256-He2YomlHHtN+myt9GvqUrBUJSV3oFVReDRf/XmOvsho=";
  };

  arch = stdenvNoCC.hostPlatform.darwinArch;

  # Describes the toolchain that mirrors XcodeDefault below.
  toolchainInfo = builtins.toFile "ToolchainInfo.plist" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Identifier</key>
      <string>com.utm.utmshim</string>
      <key>DisplayName</key>
      <string>UTM Metal Toolchain Shim</string>
    </dict>
    </plist>
  '';
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "utm";
  version = "5.0.5";

  src = fetchFromGitHub {
    owner = "utmapp";
    repo = "UTM";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Rmu2/cN8ZEc620O4ualkR0J6e3dN4nwTo/2cEI1WUts=";
  };

  passthru = {
    # Upstream resolves its Swift packages over the network. Fetch them once
    # here (a fixed-output derivation has network access) and point the build
    # at the checkout, like compositor does.
    spmDeps = stdenvNoCC.mkDerivation {
      pname = "${finalAttrs.pname}-spm-deps";
      inherit (finalAttrs) version src;

      outputHashMode = "recursive";
      outputHash = "sha256-i2SzchLWBH2u5xlYHzlpz6SoVWQeeflu/mq8Jl0W04A=";

      nativeBuildInputs = [ writableTmpDirAsHomeHook ];

      sandboxProfile = xcodeSandbox.base;

      buildCommand = ''
        export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
        export CFFIXED_USER_HOME=$HOME

        cp -a "$src" source
        chmod -R u+w source
        cd source
        mkdir -p "$out"

        env PATH="$DEVELOPER_DIR/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin''${PATH:+:$PATH}" \
          xcodebuild -resolvePackageDependencies \
            -project UTM.xcodeproj \
            -scheme macOS \
            -clonedSourcePackagesDirPath "$out" \
            -derivedDataPath "$TMPDIR/derived" \
            -onlyUsePackageVersionsFromResolvedFile \
            -IDEPackageSupportDisableManifestSandbox=YES \
            -IDEPackageSupportDisablePluginExecutionSandbox=YES

        rm -rf "$out/repositories"
        find "$out" -name .git -print0 | xargs -0 rm -rf
        find "$out" -type d -name xcuserdata -print0 | xargs -0 rm -rf
      '';
    };

    updateScript = writeShellApplication {
      name = "update-utm";
      runtimeInputs = [
        python3
        nix
        nix-update
        git
        cacert
      ];
      text = ''
        export UPDATE_NIX_ATTR_PATH="utm"
        export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
        exec ${python3}/bin/python3 ${./update.py} "$@"
      '';
    };
  };

  nativeBuildInputs = [
    unzip
    writableTmpDirAsHomeHook
  ];

  # Xcode and hdiutil need to reach the host's toolchain and disk-image
  # services, which the Nix sandbox blocks. Everything that matters is pinned
  # above (source, sysroot, Swift packages); turn the sandbox off on darwin
  # like kiwix-apple does rather than rewriting upstream's build script.
  __noChroot = stdenvNoCC.hostPlatform.isDarwin;

  # Xcode ad-hoc signs the app and its embedded frameworks and the fixup phase
  # would strip them, invalidating those signatures. Keep the bundle as built.
  dontFixup = true;

  # Resolve Swift packages from the pinned checkout instead of the network.
  # Xcode's script sandbox cannot run inside the Nix build sandbox, so turn it
  # off; the build still has no network access.
  postPatch = ''
    substituteInPlace Scripts/build_utm.sh \
      --replace-fail \
        'CODE_SIGNING_ALLOWED=NO' \
        'CODE_SIGNING_ALLOWED=NO ENABLE_USER_SCRIPT_SANDBOXING=NO OTHER_SWIFT_FLAGS="-Xfrontend -disable-sandbox"' \
      --replace-fail 'xcodebuild archive' \
        'xcodebuild -clonedSourcePackagesDirPath "$PWD/spm" -disableAutomaticPackageResolution -onlyUsePackageVersionsFromResolvedFile -skipMacroValidation -IDEPackageSupportDisableManifestSandbox=YES -IDEPackageSupportDisablePluginExecutionSandbox=YES archive'
  '';

  buildPhase = ''
    runHook preBuild

    ${xcodeSandbox.envWithPath}

    # Xcode 26's metal driver cannot find the downloaded Metal Toolchain when
    # xcodebuild runs it (Apple bug); the compiler in the mounted toolchain
    # works when called directly. Mirror XcodeDefault's toolchain in the
    # writable HOME, link the Metal compiler over the stub, and select it.
    toolchain="$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain"
    shim="$HOME/Library/Developer/Toolchains/UTMShim.xctoolchain"
    mkdir -p "$shim/usr/bin"
    for entry in "$toolchain"/*; do
      [ "$(basename "$entry")" = usr ] || ln -s "$entry" "$shim/"
    done
    for entry in "$toolchain"/usr/*; do
      [ "$(basename "$entry")" = bin ] || ln -s "$entry" "$shim/usr/"
    done
    for entry in "$toolchain"/usr/bin/*; do
      ln -s "$entry" "$shim/usr/bin/"
    done
    metal_mount="$PWD/metal-toolchain"
    metal_dmg="$(/bin/ls /System/Library/AssetsV2/com_apple_MobileAsset_MetalToolchain/*.asset/AssetData/Restore/*.dmg 2>/dev/null | head -1)"
    if [ -n "$metal_dmg" ]; then
      mkdir -p "$metal_mount"
      /usr/bin/hdiutil attach -nobrowse -readonly -mountpoint "$metal_mount" "$metal_dmg" >/dev/null
      metal_real="$metal_mount/Metal.xctoolchain/usr/bin/metal"
    else
      metal_real="$(/usr/bin/xcrun --find metal 2>/dev/null || true)"
    fi
    case "$metal_real" in
      */Metal.xctoolchain/usr/bin/metal)
        # The Metal toolchain ships its own driver and metallib; use both.
        for entry in "$(dirname "$metal_real")"/*; do
          name="$(basename "$entry")"
          rm -f "$shim/usr/bin/$name"
          ln -s "$entry" "$shim/usr/bin/$name"
        done
        ;;
      *)
        rm -f "$shim/usr/bin/metal"
        ln -s "$metal_real" "$shim/usr/bin/metal"
        ;;
    esac
    rm -f "$shim/ToolchainInfo.plist"
    cp ${toolchainInfo} "$shim/ToolchainInfo.plist"
    chmod u+w "$shim/ToolchainInfo.plist"
    export TOOLCHAINS=com.utm.utmshim
    export TOOLCHAIN_DIR="$shim"
    export DT_TOOLCHAIN_DIR="$shim"

    unzip -q ${sysroot}
    tar xzf sysroot.tgz
    rm sysroot.tgz
    # The sysroot is universal; build_utm.sh looks for the host architecture's
    # directory name. Rename it rather than symlink it: Xcode's script sandbox
    # resolves symlinks and would not declare the real path as an input.
    mv sysroot-macOS-arm64_x86_64 "sysroot-macOS-${arch}"

    mkdir -p spm
    cp -a ${finalAttrs.passthru.spmDeps}/. spm/
    chmod -R u+w spm

    # The Metal toolchain is attached as a disk image and would otherwise keep
    # the build directory from being deleted.
    ${xcodeSandbox.detachMetalToolchain}
    trap 'detach_metal_toolchain "$metal_mount"' EXIT

    ./Scripts/build_utm.sh -k macosx -s macOS -a "${arch}" -o "$PWD/UTM-out"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -R UTM-out.xcarchive/Products/Applications/UTM.app "$out/Applications/"
    ln -s ../Applications/UTM.app/Contents/MacOS/UTM "$out/bin/utm"
    ln -s ../Applications/UTM.app/Contents/MacOS/utmctl "$out/bin/utmctl"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    app="$out/Applications/UTM.app"
    test -x "$app/Contents/MacOS/UTM"
    test -x "$app/Contents/MacOS/utmctl"
    test "$(/usr/bin/plutil -extract CFBundleShortVersionString raw "$app/Contents/Info.plist")" = "${finalAttrs.version}"
    /usr/bin/plutil -lint "$app/Contents/Info.plist"
    /usr/bin/codesign --verify --deep --strict "$app"

    runHook postInstallCheck
  '';

  meta = {
    description = "Emulator and virtualizer for macOS";
    homepage = "https://mac.getutm.app/";
    downloadPage = "https://github.com/utmapp/UTM/releases";
    changelog = "https://github.com/utmapp/UTM/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode # QEMU/SPICE/GStreamer sysroot from upstream CI
    ];
    mainProgram = "utm";
    # Building needs the host Xcode and its Metal toolchain, which no Nix
    # builder provides.
    hydraPlatforms = [ ];
  };
})
