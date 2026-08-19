# Build BakaMusic's Node-API FFI dependency from its pinned rygel source with vendored headers.
{
  lib,
  stdenv,
  fetchurl,
  cmake,
  ninja,
  nodejs,
}: let
  pins = (lib.importJSON ./pins.json).koffi;

  # CNoke host triplet, with a non-building evaluation fallback.
  cnokeTriplet =
    {
      x86_64-linux = "linux_x64";
      aarch64-linux = "linux_arm64";
    }.${
      stdenv.hostPlatform.system
    } or "linux_x64";
in
  stdenv.mkDerivation {
    pname = "koffi";
    inherit (pins) version;

    src = fetchurl {
      url = "https://codeberg.org/Koromix/rygel/archive/${pins.commit}.tar.gz";
      hash = pins.hash;
    };

    nativeBuildInputs = [
      cmake
      ninja
      nodejs
    ];

    # Codeberg archive root.
    sourceRoot = "rygel";

    # Let CNoke configure the koffi subproject.
    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      # Give CNoke a writable cache directory.
      export HOME=$TMPDIR

      # Build the koffi subproject.
      node src/cnoke/cnoke.js build -D src/koffi --release

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -Dm644 bin/Koffi/${cnokeTriplet}/koffi.node \
        $out/lib/koffi/${cnokeTriplet}/koffi.node

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck

      # Verify the Node-API addon reports the pinned version.
      node -e '
        const koffi = require(process.argv[1]);
        if (koffi.version !== "${pins.version}") {
          throw new Error(`koffi version mismatch: ''${koffi.version} != ${pins.version}`);
        }
      ' $out/lib/koffi/${cnokeTriplet}/koffi.node

      runHook postInstallCheck
    '';

    meta = {
      description = "Fast and easy-to-use dynamic C FFI module for Node.js";
      homepage = "https://koffi.dev/";
      license = lib.licenses.mit;
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
  }
