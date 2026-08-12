# koffi (the Node.js FFI library BakaMusic uses to dlopen libmpv) built
# from source. nixpkgs has no koffi package and upstream only publishes
# prebuilt binaries (the @koromix/koffi-* npm packages), which this
# repository's rules forbid shipping/patchelf'ing when source is available.
# The source lives in the Koromix/rygel monorepo on Codeberg; npm releases
# map to `koffi/<version>` tags there (resolved and pinned by
# ./update-pins.sh into ./pins.json).
#
# The build uses koffi's own CNoke (a thin, dependency-free CMake wrapper
# vendored in the same monorepo) with the vendored Node-API headers
# (src/koffi/package.json cnoke.api -> vendor/node-api-headers), so nothing
# is downloaded at build time. koffi is a Node-API addon, so the result is
# not tied to a specific Node/Electron ABI.
{
  lib,
  stdenv,
  fetchurl,
  cmake,
  ninja,
  nodejs,
}: let
  pins = (lib.importJSON ./pins.json).koffi;

  # CNoke's host triplet naming: process.platform + "_" + ABI-normalized
  # process.arch. The fallback keeps evaluation (which never builds) alive
  # on non-Linux platforms; meta.platforms gates actual builds.
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

    # The Codeberg archive extracts to ./rygel.
    sourceRoot = "rygel";

    buildPhase = ''
      runHook preBuild

      # CNoke computes its cache directory from HOME in its constructor even
      # when (as here, thanks to the vendored Node-API headers) nothing is
      # ever cached there.
      export HOME=$TMPDIR

      # -D selects the koffi subproject inside the monorepo. Output lands in
      # bin/Koffi/<triplet>/koffi.node (via the cnoke.output template in
      # src/koffi/package.json).
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

      # Load the freshly built addon under plain Node (Node-API, so no
      # Electron needed) and verify it reports the pinned version — the npm
      # koffi package refuses a version-mismatched native module at runtime.
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
