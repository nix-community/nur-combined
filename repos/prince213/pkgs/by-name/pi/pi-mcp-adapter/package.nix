{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-mcp-adapter";
  version = "2.26.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-mcp-adapter";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9iKfraMl03Pg/3NhoUZgpuzEaPBxK5j+qZ0deWCPnbM=";
  };

  patches = [ ./package-lock.patch ];

  npmDepsFetcherVersion = 2;
  npmDepsHash = "sha256-A/p+3cswqnLLafv8t5B2lGFR1Wft9khdOtfqlIxXlJE=";

  npmInstallFlags = [ "--omit=dev" ];

  dontNpmBuild = true;

  postInstall = ''
    rm -rf $out/bin
    cp -r $out/lib/node_modules/pi-mcp-adapter/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "MCP adapter for Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-mcp-adapter";
    downloadPage = "https://github.com/nicobailon/pi-mcp-adapter/releases";
    changelog = "https://github.com/nicobailon/pi-mcp-adapter/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prince213 ];
  };
})
