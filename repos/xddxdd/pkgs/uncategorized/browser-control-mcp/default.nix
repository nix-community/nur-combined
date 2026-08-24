{
  fetchFromGitHub,
  lib,
  buildNpmPackage,
  nix-update-script,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  pname = "browser-control-mcp";
  version = "1.5.2";
  src = fetchFromGitHub {
    owner = "eyalzh";
    repo = "browser-control-mcp";
    tag = "v1.5.2";
    hash = "sha256-lC8/gQKK0nnJ5RC+ABmL5Pavq03ztFm9TiURONSbvtQ=";
  };
  sourceRoot = "${finalAttrs.src.name}/mcp-server";
  npmDepsHash = "sha256-C2XXxn1P3COFXdBnNzYGzQwx3GRHv3nfFUvRV8v/MI8=";

  postInstall = ''
    rm $out/lib/node_modules/mcp-server/node_modules/@browser-control-mcp/common
    cp -r ${finalAttrs.src}/common $out/lib/node_modules/mcp-server/node_modules/@browser-control-mcp/common
    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/browser-control-mcp \
      --add-flags "$out/lib/node_modules/mcp-server/dist/server.js"
  '';

  passthru.updateScript = nix-update-script { };
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "MCP server paired with a browser extension that enables AI agents to control the user's browser";
    homepage = "https://github.com/eyalzh/browser-control-mcp";
    changelog = "https://github.com/eyalzh/browser-control-mcp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    mainProgram = "browser-control-mcp";
    platforms = lib.platforms.linux;
  };
})
