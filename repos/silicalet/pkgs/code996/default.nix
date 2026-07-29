{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
  nodejs_22,
}:

buildNpmPackage (finalAttrs: {
  pname = "code996";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "hellodigua";
    repo = "code996";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+petGfuFwWR9HYVFA2XoNLo8WOciDjcLYFqmJqD0bUU=";
  };

  npmDepsHash = "sha256-miJsnztq7qsv3gHBmxUZeULRCABvvz8ORv1GL38ZGtE=";
  nodejs = nodejs_22;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Analyze Git commit timestamps to estimate project work intensity";
    homepage = "https://github.com/hellodigua/code996";
    changelog = "https://github.com/hellodigua/code996/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "code996";
    platforms = lib.platforms.all;
  };
})
