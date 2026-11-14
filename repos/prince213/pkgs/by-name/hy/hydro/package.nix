{
  lib,
  fetchFromGitHub,
  stdenvNoCC,

  # nativeBuildInputs
  makeBinaryWrapper,
  nodejs-slim_22,
  yarn-berry_4,

  # passthru
  nixosTests,
}:
let
  nodejs = nodejs-slim_22;
  yarn-berry = yarn-berry_4.override { inherit nodejs; };
  yarnBerryConfigHook = yarn-berry.yarnBerryConfigHook.override { inherit nodejs; };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hydro";
  # https://github.com/hydro-dev/Hydro/blob/master/packages/hydrooj/package.json
  version = "5.1.0";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "hydro-dev";
    repo = "Hydro";
    rev = "02563a8531e2e73e7194034d0b9ea6efe60b534f";
    fetchSubmodules = true;
    hash = "sha256-+Lp+nSkJme2SnNTYjGBWCnfzmdbyouPWTrcLCHI+RlY=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    nodejs
    yarn-berry
    yarnBerryConfigHook
  ];

  missingHashes = ./missing-hashes.json;
  offlineCache = yarn-berry.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes;
    yarnLock = ./yarn.lock;
    hash = "sha256-VKpAuaOa02UMXXdEQXktxHHAQE0ZjFhuGHzPSOM3Wco=";
  };

  patches = [
    ./paths.patch
    ./log-to-stderr.patch
  ];

  postPatch = ''
    cp ${./yarn.lock} yarn.lock

    # reproducibility
    substituteInPlace packages/ui-default/build/main.ts \
      --replace-fail "timestamp: 1577836800" "ts: 1577836800"
  '';

  env = {
    MONGOMS_DISABLE_POSTINSTALL = 1;
  };

  preBuild = ''
    node build/prepare.js
  '';

  buildPhase = ''
    runHook preBuild

    node packages/ui-default/build --iconfont
    node packages/ui-default/build --production

    runHook postBuild
  '';

  preInstall = ''
    yarn workspaces focus --all --production
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/hydro
    cp -r examples framework node_modules packages $out/lib/hydro

    mkdir -p $out/bin

    makeWrapper ${lib.getExe nodejs} $out/bin/hydrojudge \
      --add-flag $out/lib/hydro/packages/hydrojudge/bin/hydrojudge.js

    makeWrapper ${lib.getExe nodejs} $out/bin/hydrooj \
      --add-flag $out/lib/hydro/packages/hydrooj/bin/hydrooj.js

    runHook postInstall
  '';

  passthru = {
    tests = { inherit (nixosTests) hydro hydro-standalone-judge; };
  };

  meta = {
    description = "Online judge system";
    homepage = "https://github.com/hydro-dev/Hydro";
    license = with lib.licenses; [
      agpl3Only
      # packages/hydrojudge/vendor/testlib
      mit
    ];
    maintainers = with lib.maintainers; [ prince213 ];
    mainProgram = "hydrooj";
    platforms = lib.platforms.linux;
  };
})
