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
  version = "1.76.0";

  src = fetchFromGitHub {
    owner = "gorhill";
    repo = "uBlock";
    rev = finalAttrs.version;
    hash = "sha256-Wrl8B1Du7bcKtzevDgdbnLYoRCPJwpGXIiYUUROr73E=";
  };

  uAssetsMain = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "6375a4e395537e2a5baf9ef487d2c462eeca393e";
    hash = "sha256-BTNyziseiRgl5GQH7jh9frKsJ9Xv8a0vMaMF1vNnVhQ=";
  };

  uAssetsProd = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "41bec966e46a944739b44b2b2ddcb2357b3c6e4b";
    hash = "sha256-8PdFdyUnYqwgXP/NMn1BGlhI7wj27Vzyhxf7uToyJmE=";
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
