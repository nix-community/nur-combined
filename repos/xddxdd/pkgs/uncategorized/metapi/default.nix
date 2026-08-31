{
  fetchFromGitHub,
  lib,
  buildNpmPackage,
  nix-update-script,
  nodejs,
}:
buildNpmPackage (finalAttrs: {
  pname = "metapi";
  version = "1.3.0";
  src = fetchFromGitHub {
    owner = "cita-777";
    repo = "metapi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OfS8iAjP1yU40RNlJeFEvih4jn9Ab4joTgLfRD6e1pQ=";
  };
  npmDepsHash = "sha256-6C4SIoP0+HdIoODkWq6uEJppOOfzFiNf/5FEtTG/Eo0=";

  npmFlags = [ "--ignore-scripts" ];

  preBuild = ''
    npm rebuild esbuild sharp better-sqlite3
  '';

  installPhase = ''
    runHook preInstall

    npm prune --omit=dev --no-audit --no-fund
    mkdir -p $out/lib/node_modules/metapi
    cp -r dist node_modules package.json drizzle $out/lib/node_modules/metapi/
    makeWrapper ${lib.getExe nodejs} $out/bin/metapi \
      --add-flags "$out/lib/node_modules/metapi/dist/server/index.js"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    changelog = "https://github.com/cita-777/metapi/releases/tag/v${finalAttrs.version}";
    mainProgram = "metapi";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Meta-layer management and unified proxy for AI API aggregation platforms";
    homepage = "https://github.com/cita-777/metapi";
    license = lib.licenses.mit;
  };
})
