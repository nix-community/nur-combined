{
  lib,
  stdenv,
  fetchFromGitHub,
  zig_0_16,
  pkg-config,
  dbus,
  patchelf,
  makeBinaryWrapper,
  nix-update-script,
  writeShellApplication,
}:

stdenv.mkDerivation (
  finalAttrs:
  {
    pname = "whereami";
    version = "0.4.0";

    src = fetchFromGitHub {
      owner = "georgemandis";
      repo = "whereami";
      tag = "v${finalAttrs.version}";
      hash = "sha256-LDY9HEFhFTWTsYK8Ugh7K8GOxpYIlQRHBbydXcOk63c=";
    };

    # Upstream requires Zig 0.16; Linux builds against libdbus-1, macOS links
    # CoreLocation/Foundation.
    nativeBuildInputs = [
      zig_0_16
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      pkg-config
      patchelf
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [ makeBinaryWrapper ];

    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ dbus ];

    dontConfigure = true;

    # Stripping invalidates upstream's ad-hoc bundle signature, and the darwin
    # fixup would re-sign with the wrong identifier for CoreLocation.
    dontFixup = stdenv.hostPlatform.isDarwin;

    buildPhase = ''
      runHook preBuild

      export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-global-cache
      export ZIG_LOCAL_CACHE_DIR=$TMPDIR/zig-local-cache

      ${lib.optionalString stdenv.hostPlatform.isDarwin ''
        # CoreLocation only grants access to signed bundles, so use upstream's
        # bundle step. It hardcodes zig-out/, hence no --prefix here.
        # Zig must link the host SDK (the Nix apple-sdk lacks libobjc), so drop
        # stdenv's SDK/DEVELOPER_DIR and -L flags, and use the system codesign.
        env -u SDKROOT -u DEVELOPER_DIR -u NIX_LDFLAGS -u NIX_CFLAGS_COMPILE \
          PATH="/usr/bin:$PATH" \
          zig build bundle -Doptimize=ReleaseSafe --summary all
      ''}
      ${lib.optionalString stdenv.hostPlatform.isLinux ''
        zig build -Doptimize=ReleaseSafe --prefix "$out" --summary all
      ''}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      ${lib.optionalString stdenv.hostPlatform.isDarwin ''
        mkdir -p "$out/Applications" "$out/bin"
        cp -R zig-out/whereami.app "$out/Applications/"
        makeBinaryWrapper \
          "$out/Applications/whereami.app/Contents/MacOS/whereami" \
          "$out/bin/whereami"
      ''}
      runHook postInstall
    '';

    postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
      # Zig links with its own linker, so stdenv's rpath fixup does not run.
      patchelf --set-rpath ${lib.makeLibraryPath [ dbus ]} "$out/bin/whereami"
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      "$out/bin/whereami" --mock=40.7128,-74.0060 --json
      runHook postInstallCheck
    '';

    passthru.updateScript = writeShellApplication {
      name = "update-whereami";
      text = ''
        export UPDATE_NIX_ATTR_PATH="whereami"
        exec ${lib.escapeShellArgs (nix-update-script { })} "$@"
      '';
    };

    meta = {
      description = "Get your location from the command line using native OS location services";
      homepage = "https://github.com/georgemandis/whereami";
      changelog = "https://github.com/georgemandis/whereami/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.mit;
      mainProgram = "whereami";
      platforms = lib.platforms.linux ++ lib.platforms.darwin;
    };
  }
  // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Xcode's codesign/SDK live outside the Nix store; the darwin sandbox only
    # exposes a fixed set of system paths.
    __noChroot = true;
  }
)
