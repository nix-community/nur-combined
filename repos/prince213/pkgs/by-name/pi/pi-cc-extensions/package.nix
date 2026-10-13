{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-cc-extensions";
  version = "1.0.3";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "minuque";
    repo = "pi-cc-extensions";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bvNo0zkR4VD+S0xxLWnMdSADPLfV5noqEH3HvibKJBA=";
  };

  patches = [ ./displayPath.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-zV9MFc50IlGvHCHaat3eyf6tMnzP3ms/SLdJCWTYzsw=";

  npmPruneFlags = [ "--omit=peer" ];

  dontNpmBuild = true;

  postInstall = ''
    cp -r $out/lib/node_modules/pi-cc-extensions/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Claude Code-style TUI output and utilities for the Pi coding agent";
    homepage = "https://github.com/minuque/pi-cc-extensions";
    downloadPage = "https://github.com/minuque/pi-cc-extensions/releases";
    changelog = "https://github.com/minuque/pi-cc-extensions/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
