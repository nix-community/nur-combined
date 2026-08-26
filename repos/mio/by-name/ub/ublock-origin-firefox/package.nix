{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  bash,
  python3,
  zip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ublock-origin-firefox";
  version = "1.74.0";

  src = fetchFromGitHub {
    owner = "gorhill";
    repo = "uBlock";
    rev = finalAttrs.version;
    hash = "sha256-FWyyWAC6wpY3W88gKyFMDAj5zKyA0aTe57THfdUNGMY=";
  };

  uAssetsMain = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "7f3ce24fb1f0674a4d56e4b079437cade287eea5";
    hash = "sha256-ye4ZuVCjrHxn1Orc1IVUNDYioQxZwxCYqFKpKVCLMuU=";
  };

  uAssetsProd = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "1914968199546cf2e3c37e464339b321cf6d2b02";
    hash = "sha256-WYZrImKCd6i9E7BFBKbObDX4z9D1YRJnjRfCO4caX1s=";
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
  };

  meta = {
    description = "uBlock Origin Firefox add-on built from source";
    homepage = "https://github.com/gorhill/uBlock";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
  };
})
