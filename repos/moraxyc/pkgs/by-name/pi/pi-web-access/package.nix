{
  lib,
  buildNpmPackage,
  importNpmLock,

  sources,
  source ? sources.pi-web-access,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;

  npmDeps = importNpmLock {
    package =
      let
        package = lib.importJSON source.extract."package.json";
      in
      package
      // {
        # Only esbuild and the standalone MCP bundle's typebox are needed to build.
        devDependencies = lib.getAttrs [ "esbuild" "typebox" ] package.devDependencies;
      };
    packageLock =
      let
        lock = lib.importJSON source.extract."package-lock.json";
      in
      lock
      // {
        packages = lib.filterAttrs (
          name: package:
          !(package.dev or false)
          || builtins.elem name [
            "node_modules/esbuild"
            "node_modules/typebox"
          ]
          || lib.hasPrefix "node_modules/@esbuild/" name
        ) lock.packages;
      };
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  npmFlags = [ "--legacy-peer-deps" ];
  dontNpmPrune = true;

  postBuild = ''
    node scripts/pi-extensions-dist.js dist
  '';

  preInstall = ''
    rm -rf node_modules/{esbuild,@esbuild,typebox,.bin/esbuild}
  '';

  postInstall = ''
    mv $out/lib/node_modules/pi-web-access $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules
    rm -f "$out/lib/${finalAttrs.pname}/node_modules/.package-lock.json"
    # Pi loads the prebuilt dist bundle; TypeScript sources and media are unused.
    rm $out/lib/${finalAttrs.pname}/{*.ts,banner.png,pi-web-fetch-demo.mp4,SECURITY.md}
    substituteInPlace $out/bin/pi-web-access-mcp \
      --replace-fail "$out/lib/node_modules/pi-web-access" "$out/lib/${finalAttrs.pname}"
  '';

  meta = {
    description = "Web search and content extraction for the Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-web-access";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "pi-web-access-mcp";
  };
})
