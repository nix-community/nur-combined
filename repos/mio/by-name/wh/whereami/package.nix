{
  lib,
  stdenv,
  fetchFromGitHub,
  zig_0_16,
  pkg-config,
  dbus,
  patchelf,
  nix-update-script,
  writeShellApplication,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "whereami";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "georgemandis";
    repo = "whereami";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LDY9HEFhFTWTsYK8Ugh7K8GOxpYIlQRHBbydXcOk63c=";
  };

  # Upstream requires Zig 0.16 and builds the Linux backend against libdbus-1.
  nativeBuildInputs = [
    zig_0_16
    pkg-config
    patchelf
  ];

  buildInputs = [ dbus ];

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-global-cache
    export ZIG_LOCAL_CACHE_DIR=$TMPDIR/zig-local-cache

    zig build -Doptimize=ReleaseSafe --prefix "$out" --summary all

    runHook postBuild
  '';

  # zig build already installed the binary and the .desktop file.
  installPhase = ''
    runHook preInstall
    runHook postInstall
  '';

  # Zig links with its own linker, so stdenv's rpath fixup does not run.
  postFixup = ''
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
    # The macOS build needs an ad-hoc-signed .app bundle for CoreLocation
    # permissions; only the Linux (GeoClue2) backend is packaged here.
    platforms = lib.platforms.linux;
  };
})
