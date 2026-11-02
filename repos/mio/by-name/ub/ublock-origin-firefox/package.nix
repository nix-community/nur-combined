{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bash,
  python3,
  zip,
  writeShellApplication,
  git,
  nix,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ublock-origin-firefox";
  version = "1.75.2";

  src = fetchFromGitHub {
    owner = "gorhill";
    repo = "uBlock";
    rev = finalAttrs.version;
    hash = "sha256-LSOxN1CGd3XNae2PH9WKX5DEwF5ce0t5h2Y8we62d5Q=";
  };

  uAssetsMain = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "205b2124e08665b31ba6f1020378fa2ebbc67a6b";
    hash = "sha256-usQWrpUdcS3RovowXRu1ek2/4/4q4L4CrZ9tf6Y4jbY=";
  };

  uAssetsProd = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "6aa26491a2a4e7fc8974c98baad25246dcbcf5d8";
    hash = "sha256-yB+RXMT2aSNcvXct7Oqs1e+G8qgJ7XtBwkQdp0n2+js=";
  };

  nativeBuildInputs = [
    bash
    python3
    zip
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p dist/build/uAssets
    cp -r ${finalAttrs.uAssetsMain} dist/build/uAssets/main
    cp -r ${finalAttrs.uAssetsProd} dist/build/uAssets/prod
    bash ./tools/make-firefox.sh all

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 dist/build/uBlock0.firefox.xpi "$out/uBlock0@raymondhill.net.xpi"
    ln -s uBlock0@raymondhill.net.xpi "$out/uBlock0.firefox.xpi"

    runHook postInstall
  '';

  passthru = {
    extid = "uBlock0@raymondhill.net";
    updateScript = writeShellApplication {
      name = "update-ublock-origin-firefox";
      runtimeInputs = [
        python3
        git
        nix
      ];
      text = ''
        export UPDATE_NIX_ATTR_PATH="ublock-origin-firefox"
        exec ${python3}/bin/python3 ${./update.py} "$@"
      '';
    };
  };

  meta = {
    description = "uBlock Origin Firefox add-on built from source";
    homepage = "https://github.com/gorhill/uBlock";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
})
