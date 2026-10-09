{
  fetchFromGitHub,
  lib,
  buildNpmPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-web";
  version = "0.11.0";
  src = fetchFromGitHub {
    owner = "agegr";
    repo = "pi-web";
    tag = "v${finalAttrs.version}";
    hash = "sha256-C1cdlyi7YRNjLXymObg4dHuvEkMutASkICykPlk2X24=";
  };
  __structuredAttrs = true;
  strictDeps = true;

  npmDepsHash = "sha256-QLW4ZwfDHx6T9D0eHoB/hjAjQlZdGKlQcPQz08Pz8wg=";

  patches = [ ./no-google-font.patch ];

  # Generated lockfile; the lockfile shipped by upstream is a bun secondary
  # artifact that prefetch-npm-deps rejects (shrinkwrap subtrees without
  # integrity panic it, plus stale zod resolution and missing platform
  # optionals).
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
  '';

  makeCacheWritable = true;

  dontNpmPrune = true;

  # Build needs devDependencies (tailwind, remark/rehype, typescript, ...);
  # slim the runtime tree back to production deps after the build. npm ci
  # rebuilds node_modules from scratch, avoiding the npm prune arborist bug
  # documented in AGENTS.md.
  postBuild = ''
    npm ci --omit=dev --ignore-scripts
  '';

  makeWrapperArgs = [
    "--set"
    "NODE_ENV"
    "production"
  ];

  passthru.updateScript = [ (toString ./update.sh) ];

  meta = {
    description = "Web UI for the pi coding agent";
    homepage = "https://github.com/agegr/pi-web";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ xddxdd ];
    mainProgram = "pi-web";
    platforms = lib.platforms.linux;
  };
})
