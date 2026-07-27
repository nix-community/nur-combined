{
  sources,

  lib,

  buildNpmPackage,
  importNpmLock,
}:
buildNpmPackage {
  inherit (sources.mcp-searxng) pname src;
  version = lib.removePrefix "v" sources.mcp-searxng.version;

  npmDeps = importNpmLock {
    package = lib.importJSON sources.mcp-searxng.extract."package.json";
    packageLock = lib.importJSON sources.mcp-searxng.extract."package-lock.json";
    npmRoot = ".";
  };
  inherit (importNpmLock) npmConfigHook;

  meta = {
    description = "MCP Server for SearXNG";
    homepage = "https://github.com/ihor-sokoliuk/mcp-searxng";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "mcp-searxng";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
