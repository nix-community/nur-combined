{
  lib,
  buildNpmPackage,
  importNpmLock,

  sources,
  source ? sources.pi-mcp-adapter,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) src version pname;

  npmDeps = importNpmLock {
    package = lib.importJSON source.extract."package.json";
    packageLock =
      let
        lock = lib.importJSON source.extract."package-lock.json";
        prefix = "node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/";
      in
      lock
      // {
        packages = lib.filterAttrs (name: _: !(lib.hasPrefix prefix name)) (lock.packages or { });
      };
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  npmInstallFlags = [ "--omit=dev" ];
  npmPackFlags = [ "--ignore-scripts" ];

  dontNpmBuild = true;

  meta = {
    description = "MCP adapter for Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-mcp-adapter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
