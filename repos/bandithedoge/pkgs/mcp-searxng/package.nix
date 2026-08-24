{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "mcp-searxng";
  version = "2.0.0";
  src = fetchFromGitHub {
    owner = "ihor-sokoliuk";
    repo = "mcp-searxng";
    rev = "v${finalAttrs.version}";
    hash = "sha256-zakEU/6eeYClbj8VsSU0T6OqG0rl5iXUPSdAife4Juo=";
  };

  npmDepsHash = "sha256-4WUOJJU9fXLVPE8ryB1IMWKVg5OL743VjupctYpPH0Y=";

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
