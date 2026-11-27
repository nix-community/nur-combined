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
  version = "1.77.2";

  src = fetchFromGitHub {
    owner = "gorhill";
    repo = "uBlock";
    rev = finalAttrs.version;
    hash = "sha256-dfiIVAxFsznE13P1qs8eO2n0VWGQ2kCmHum3Pqm2blQ=";
  };

  uAssetsMain = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "641810ea69f999b6d5bad9f610a85385f9f3fd29";
    hash = "sha256-x+iwG48L2y9DQK6HxzhGXog+KknJaE674pM7jEJtzJQ=";
  };

  uAssetsProd = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "d0dc6e5143d98789a49026642c8ed550002f4572";
    hash = "sha256-/ErRDwXSaGgxSV5eqKgqN9fNSrXnIIi+m9cwl2afDsY=";
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
