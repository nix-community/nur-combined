{
  lib,
  stdenv,
  fetchFromGitHub,
  python312,
  rustPlatform,
  cmake,
  makeWrapper,
  makeDesktopItem,
  copyDesktopItems,
  cacert,
}:

let
  version = "1.10.1-beta.dev.635";

  python = python312.withPackages (
    ps: with ps; [
      numpy
      pillow
      duckdb
      fsspec
      certifi
      truststore
    ]
  );

  src = fetchFromGitHub {
    owner = "TecnaGamer";
    repo = "BeamNG.Earth";
    tag = "v${version}";
    hash = "sha256-TvpPJpIK7ctlCsXHCvCg6xPm9Ru2VckTBbmX1iNPu1c=";
  };

  # The world server's geometry kernels (native/earthfast): a pyo3 abi3
  # extension, so one build serves every Python >= 3.10.
  earthfast = rustPlatform.buildRustPackage {
    pname = "earthfast";
    inherit version src;

    cargoRoot = "native/earthfast";
    buildAndTestSubdir = "native/earthfast";
    cargoHash = "sha256-vtUKyB8wn3Ixqq5mTHwaEjp9qBVEbYcTyhbNrwechDE=";

    # turbojpeg-sys builds its bundled libjpeg-turbo with CMake.
    nativeBuildInputs = [
      cmake
      python312
    ];
    env.PYO3_PYTHON = "${python312.interpreter}";

    doCheck = false;

    # The cargo setup hook makes zstd-sys look for a system libzstd, but
    # upstream builds zstd's bundled C source and nixpkgs has no static zstd.
    preBuild = "unset ZSTD_SYS_USE_PKG_CONFIG";

    installPhase = ''
      runHook preInstall
      # The build hook passes --target, so cargo writes under the target triple.
      install -Dm755 "$(find target -name libearthfast.so -print -quit)" $out/lib/earthfast.abi3.so
      runHook postInstall
    '';
  };
in
stdenv.mkDerivation {
  pname = "beamng-earth";
  inherit version src;

  patches = [ ./install-paths.patch ];

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    python
  ];

  buildInputs = [ python ];

  # tools/gcpatch is preloaded into the game by the launcher; upstream ships
  # its source, so build the same shared library here.
  buildPhase = ''
    runHook preBuild
    ( cd tools/gcpatch && CC=cc sh ./build.sh )
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    app=$out/share/beamng-earth
    mkdir -p "$app"
    cp -a . "$app/"
    chmod -R u+w "$app"

    # Build and test trees are not part of the runtime.
    rm -rf "$app/docs" "$app/.github" "$app/server/tests" "$app/mod/tests"

    # The checkout carries a prebuilt x86-64 module; use the one built above.
    rm -f "$app/server/earthfast.abi3.so" "$app/server/earthfast.pyd"
    install -Dm755 ${earthfast}/lib/earthfast.abi3.so "$app/server/earthfast.abi3.so"

    mkdir -p "$out/share/icons/hicolor/256x256/apps"
    ${python}/bin/python - "$app/mod/beamng_earth/levels/beamng_earth/beamng_earth_preview.jpg" \
      "$out/share/icons/hicolor/256x256/apps/beamng-earth.png" <<'PY'
    import sys
    from PIL import Image

    im = Image.open(sys.argv[1])
    s = min(im.size)
    im = im.crop(
        ((im.width - s) // 2, (im.height - s) // 2, (im.width + s) // 2, (im.height + s) // 2)
    )
    im.convert("RGBA").resize((256, 256), Image.LANCZOS).save(sys.argv[2])
    PY

    copyDesktopItems

    # The launcher installs the mod, starts the world server and the game.
    makeWrapper ${python}/bin/python3 "$out/bin/beamng-earth" \
      --add-flags "$app/launcher.py" \
      --set-default SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-certificates.crt"

    # The same entry points upstream documents for a source checkout. The
    # server's requirements are already in the Python above, so the patched
    # installer and start.py use it instead of making a pip venv.
    makeWrapper ${python}/bin/python3 "$out/bin/beamng-earth-install" \
      --add-flags "$app/install.py" \
      --set BEAMNG_EARTH_SYSTEM_PYTHON 1 \
      --set-default SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-certificates.crt"

    makeWrapper ${python}/bin/python3 "$out/bin/beamng-earth-start" \
      --add-flags "$app/start.py" \
      --set BEAMNG_EARTH_SYSTEM_PYTHON 1 \
      --set-default SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-certificates.crt"

    makeWrapper ${python}/bin/python3 "$out/bin/beamng-earth-server" \
      --add-flags "$app/server/earthd.py" \
      --set-default SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-certificates.crt"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "beamng-earth";
      exec = "beamng-earth";
      icon = "beamng-earth";
      desktopName = "BeamNG.Earth";
      comment = "1:1 scale streamed Earth and its companion world server for BeamNG.drive";
      categories = [ "Game" ];
      terminal = true;
    })
  ];

  passthru = {
    inherit earthfast;
    updateScript = ./update.sh;
  };

  meta = {
    description = "1:1 scale streamed Earth for BeamNG.drive, with its companion world server";
    homepage = "https://github.com/TecnaGamer/BeamNG.Earth";
    license = lib.licenses.mit;
    mainProgram = "beamng-earth";
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
}
