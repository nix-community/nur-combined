{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-claude-code-ui";
  version = "1.0.86";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "FammasMaz";
    repo = "pi-cc-tools";
    rev = "14e130d6968651cdc4a56d39e4d3ed6721796643";
    hash = "sha256-CHdlYYlIYOeNag6seNPGJQJnI3iT8MMw0LJ2N8aqYbc=";
  };

  patches = [ ./package-lock.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-s1nHq4UBXoZdwTbJGO71GSZNvH87MdEnCjCFI2vcF6Q=";

  npmInstallFlags = [ "--omit=dev" ];

  dontNpmBuild = true;

  postInstall = ''
    cp -r $out/lib/node_modules/pi-claude-code-ui/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Claude Code-style grouped tool rows for the Pi coding agent";
    homepage = "https://github.com/FammasMaz/pi-cc-tools";
    changelog = "https://github.com/FammasMaz/pi-cc-tools/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
