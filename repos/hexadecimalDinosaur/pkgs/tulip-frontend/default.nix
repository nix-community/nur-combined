{
  stdenv,
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  nodejs,
  yarn,
  fixup-yarn-lock,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "tulip-frontend";
  version = "1.0.1-2025.07.03.unstable";

  src = fetchFromGitHub {
    owner = "OpenAttackDefenseTools";
    repo = "tulip";
    rev = "86f62ee5a73e8080af31bb7c27b8c89e6b16d342";
    hash = "sha256-xJCesNowkPqPP+mkUykSAkN+vKuasVVqBUp8vmYWKms=";
  };

  sourceRoot = "${finalAttrs.src.name}/frontend";

  offlineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/frontend/yarn.lock";
    hash = "sha256-dned/D4GnNrDFb7JD23Z0/+HZiRBvG4OwF0Pytf9HAo=";
  };

  nativeBuildInputs = [
    nodejs
    yarn
    fixup-yarn-lock
  ];

  configurePhase = ''
    runHook preConfigure

    export HOME="$PWD"
    fixup-yarn-lock yarn.lock
    yarn config --offline set yarn-offline-mirror ${finalAttrs.offlineCache}
    yarn install --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive
    patchShebangs node_modules

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    yarn build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    mkdir $out/tulip-frontend
    cp -r dist/* $out/tulip-frontend

    runHook postInstall
  '';

  meta = {
    description = "Network analysis tool for Attack Defence CTF";
    homepage = "https://github.com/OpenAttackDefenseTools/tulip/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ivyfanchiang ];
  };
})
