{
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
  lib,
}:
buildNpmPackage (finalAttrs: {
  pname = "mcp-searxng";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "ihor-sokoliuk";
    repo = "mcp-searxng";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Zq6oKXxmo+jaiSCGOsEB76y4xTEqU+WC1eQVFzsazXQ=";
  };

  npmDepsHash = "sha256-YIH/5RIdF/iSnUT+rWFUCKiwn3oPr1GJsgYvriJt0co=";

  strictDeps = true;

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--flake"
      ];
    };
  };

  meta = {
    mainProgram = "mcp-searxng";
    description = "MCP Server for SearXNG";
    homepage = "https://github.com/ihor-sokoliuk/mcp-searxng";
    changelog = "https://github.com/ihor-sokoliuk/mcp-searxng/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
  };
})
