{
  lib,
  buildNpmPackage,
  makeWrapper,
  nodejs-slim,
  versionCheckHook,

  sources,
  source ? sources.airtrail,
}:

buildNpmPackage (finalAttrs: {

  inherit (source) pname version src;

  nodejs = nodejs-slim;

  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-gbkWc8uIomJidA/dwr1k+t4WmkaqLb6A4CfdDrYF1gw=";
  npmFlags = [ "--legacy-peer-deps" ];
  npmRebuildFlags = [ "--ignore-scripts" ];

  env = {
    PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1";
    PUPPETEER_SKIP_DOWNLOAD = "1";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs-slim.npm
  ];

  installPhase = ''
    runHook preInstall

    npm prune --omit=dev --no-save --ignore-scripts --legacy-peer-deps --no-audit --no-fund

    appDir=$out/share/airtrail
    mkdir -p "$appDir/"{prisma,docker}

    cp -R build package.json node_modules "$appDir/"
    cp -R prisma/migrations "$appDir/prisma/"
    cp docker/{admin,migrate}.js "$appDir/docker/"

    mkdir -p $out/bin

    makeWrapper ${lib.getExe finalAttrs.nodejs} $out/bin/airtrail \
      --add-flags "$appDir/build/index.js" \
      --set NODE_ENV production \
      --chdir "$appDir"

    makeWrapper ${lib.getExe finalAttrs.nodejs} $out/bin/airtrail-migrate \
      --add-flags "$appDir/docker/migrate.js" \
      --chdir "$appDir"

    makeWrapper ${lib.getExe finalAttrs.nodejs} $out/bin/airtrail-admin \
      --add-flags "$appDir/docker/admin.js" \
      --chdir "$appDir"

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/airtrail-admin";
  versionCheckProgramArg = "version";

  # nix-update auto --version=skip --generate-lockfile
  # passthru.updateScript = nix-update-script {
  #   extraArgs = [
  #     "--version=skip"
  #     "--generate-lockfile"
  #   ];
  # };

  meta = {
    description = "Self-hosted personal flight tracker";
    homepage = "https://github.com/johanohly/AirTrail";
    changelog = "https://github.com/johanohly/AirTrail/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "airtrail";
  };
})
