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
  version = "1.76.2";

  src = fetchFromGitHub {
    owner = "gorhill";
    repo = "uBlock";
    rev = finalAttrs.version;
    hash = "sha256-vMOnoFXJc4Xkk0DmEz+2wTGEzF+X9gbKx5OepQz4uAM=";
  };

  uAssetsMain = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "33fd9cc411ec1715d1ad1a90bfd80f262b79a097";
    hash = "sha256-a0NHJvHU3m/MVX4c2z7KLibCpDYUmrvtHtYURYfY7To=";
  };

  uAssetsProd = fetchFromGitHub {
    owner = "uBlockOrigin";
    repo = "uAssets";
    rev = "b95e1fe15aa589fffba84b484d88d8330b11ef5c";
    hash = "sha256-jePHiS5gYeJaPnvLDLi/1c7nmFtRgpqSLXm1truZ5ic=";
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
