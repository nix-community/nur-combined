{
  lib,
  buildNpmPackage,
  nix-update-script,
  fetchFromGitHub,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "metapi";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "cita-777";
    repo = "metapi";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OfS8iAjP1yU40RNlJeFEvih4jn9Ab4joTgLfRD6e1pQ=";
  };

  npmDepsHash = "sha256-6C4SIoP0+HdIoODkWq6uEJppOOfzFiNf/5FEtTG/Eo0=";

  nodejs = nodejs_22;

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  postPatch = ''
    touch .npmignore
  '';

  npmBuildScript = "build:web";

  postBuild = ''
    npm run build:server
  '';

  postInstall = ''
    makeWrapper ${lib.getExe nodejs_22} "$out/bin/metapi-migrate" \
      --add-flags "$out/lib/node_modules/metapi/dist/server/db/migrate.js" \
      --set-default NODE_ENV production

    makeWrapper ${lib.getExe nodejs_22} "$out/bin/metapi" \
      --add-flags "$out/lib/node_modules/metapi/dist/server/index.js" \
      --set-default NODE_ENV production \
      --set-default PORT 4000
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Meta-layer management and unified proxy for AI API aggregation platforms";
    longDescription = ''
      Metapi is a meta-aggregation layer that unifies multiple AI API gateway
      sites (New API, One API, OneHub, DoneHub, Veloera, AnyRouter, Sub2API,
      OpenAI/Claude/Gemini compatible endpoints, etc.) into a single API key
      and entry point with automatic model discovery, smart routing, and
      cost-optimized selection.
    '';
    homepage = "https://github.com/cita-777/metapi";
    changelog = "https://github.com/cita-777/metapi/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "metapi";
    platforms = lib.platforms.unix;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
