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
  version = "1.76.6";

  src = fetchFromGitHub {
    owner = "gorhill";
    repo = "uBlock";
    rev = finalAttrs.version;
    hash = "sha256-OZfSafiUGdw42jK4XpZnycsfXOdJ+YUO51/j/hiOGVc=";
  };

  uAssetsMain = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "529ac17965b41bac46e29d35feaeee8ca4f18e10";
    hash = "sha256-kDshV6VUp4XSOmcmRLAMQabx4kaQBgVeHy+iPbz+rPc=";
  };

  uAssetsProd = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "07ebc61aede7827cf2fad99c400d6f8ab739160d";
    hash = "sha256-/PcFWq4n6b+65hYg8gmfJfHHxKc12oHc0EiCRnyp6eU=";
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
