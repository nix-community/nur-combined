{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-cc-extensions";
  version = "0.9.12";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "minuque";
    repo = "pi-cc-extensions";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Wb4+12CCrrFG+Dy4znjSS+BuzmR6+Z00rQteJE4X3RI=";
  };

  patches = [
    ./displayPath.patch
    ./package-lock.patch
  ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-CPA4+GMWgRN6i6rRiMBKAzpPQswpbdNS62q8Fg3HrMo=";

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
