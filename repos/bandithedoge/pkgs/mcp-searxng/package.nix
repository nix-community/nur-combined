{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "MCP Server for SearXNG";
    homepage = "https://github.com/ihor-sokoliuk/mcp-searxng";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "mcp-searxng";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
