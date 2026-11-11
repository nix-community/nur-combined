{
  fetchFromGitHub,
  lib,
  buildNpmPackage,
  nix-update-script,
  nodejs,
}:
buildNpmPackage (finalAttrs: {
  pname = "metapi";
  version = "1.3.1";
  src = fetchFromGitHub {
    owner = "cita-777";
    repo = "metapi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FdeDnTi/XDUdtKvKbBs83ThkGEjU3yG3J6fistZeiT8=";
  };
  __structuredAttrs = true;
  strictDeps = true;
  npmDepsHash = "sha256-EURkPGlwtJrcBcw/Gypg5Nm5Hl9JgYLhv/uvOX3CisQ=";

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
      --set NODE_ENV production \
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
