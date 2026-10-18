{
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
  lib,
}:
buildNpmPackage (finalAttrs: {
  pname = "mcp-searxng";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "ihor-sokoliuk";
    repo = "mcp-searxng";
    rev = "v${finalAttrs.version}";
    hash = "sha256-dbxJSSzwuJtwTSQN9JmGayISi4KKFly70rXk/U9/Fts=";
  };

  npmDepsHash = "sha256-+df6oLBlw8fE6baGs2G5Vmn2lQvyfLhg/2s9axuVNwo=";

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
