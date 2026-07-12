{
  sources,
  lib,
  buildNpmPackage,
  nodejs,
}:

buildNpmPackage (finalAttrs: {
  inherit (sources.mcp-proxy-server) pname version src;

  npmDepsHash = "sha256-75XZwzQANfMG9spmHjoBAJtJK1SwTzA5rz5EUdbLt14=";

  postPatch = ''
    sed -i "s/\"version\": \"[^\"]*\"/\"version\": \"${finalAttrs.version}\"/" package.json
  '';

  postInstall = ''
    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/mcp-proxy-server \
      --add-flags "$out/lib/node_modules/mcp-proxy-server/build/index.js"
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "MCP proxy server that aggregates and serves multiple MCP resource servers through a single interface";
    homepage = "https://github.com/adamwattis/mcp-proxy-server";
    license = lib.licenses.mit;
    mainProgram = "mcp-proxy-server";
    platforms = lib.platforms.linux;
  };
})
