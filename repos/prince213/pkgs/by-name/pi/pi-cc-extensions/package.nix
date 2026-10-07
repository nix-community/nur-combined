{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-cc-extensions";
  version = "0.9.11";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "minuque";
    repo = "pi-cc-extensions";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wSg6gBHGJzf1Pb4nqqJGwfoJZ4wbQTqemsho1cUoqsI=";
  };

  patches = [
    ./displayPath.patch
    ./package-lock.patch
  ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-pMxlhOL1m7L2vW01ITdvLfehH6t7dwGf/Lf3zYQamHs=";

  npmInstallFlags = [ "--omit=dev" ];

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
