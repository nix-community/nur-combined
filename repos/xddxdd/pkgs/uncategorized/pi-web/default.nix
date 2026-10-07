{
  fetchFromGitHub,
  lib,
  buildNpmPackage,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-web";
  version = "0.10.0";
  src = fetchFromGitHub {
    owner = "agegr";
    repo = "pi-web";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dDE+m6ZpiC4N2xWNMvhRshCjqFU5gr2+t7RpvC9dNUk=";
  };
  __structuredAttrs = true;
  strictDeps = true;

  npmDepsHash = "sha256-eR2dkQt8nyFJ0cRTypCJK1W2b7gl9haL9CsppYHC7oU=";

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
