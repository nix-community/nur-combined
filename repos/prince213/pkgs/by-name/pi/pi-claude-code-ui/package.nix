{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-claude-code-ui";
  version = "1.0.92";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "FammasMaz";
    repo = "pi-cc-tools";
    rev = "5458fde95dc957843bd8109198a75a43cac7df28";
    hash = "sha256-3yPXSVmzOr9L/koqnZi11uGtLWqQssIruXkg2S0OKM0=";
  };

  patches = [ ./package-lock.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-6U+Puuru0mDTEhM8GwZIde31Wz3DwuMyqr+0cqjrTL4=";

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
