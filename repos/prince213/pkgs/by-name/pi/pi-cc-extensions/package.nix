{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-cc-extensions";
  version = "0.9.9";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "minuque";
    repo = "pi-cc-extensions";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xJ64BWV617bMmj9AXVTCY0qhAo7ByTgckyjOKQ/r8A0=";
  };

  patches = [
    ./displayPath.patch
    ./package-lock.patch
  ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-ydWBpNh7M+FZPbhQdOFysZT6owJbNotgSdeQuPorniI=";

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
