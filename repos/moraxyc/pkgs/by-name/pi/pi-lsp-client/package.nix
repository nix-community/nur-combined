{
  lib,
  buildNpmPackage,
  importNpmLock,

  sources,
  source ? sources.pi-lsp-client,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;

  npmDeps = importNpmLock {
    package = removeAttrs (lib.importJSON source.extract."package.json") [ "devDependencies" ];
    packageLock =
      let
        lock = lib.importJSON source.extract."package-lock.json";
      in
      lock
      // {
        packages = lib.filterAttrs (_: package: !(package.dev or false)) lock.packages;
      };
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  npmInstallFlags = [ "--omit=dev" ];
  npmFlags = [ "--legacy-peer-deps" ];
  dontNpmBuild = true;
  dontNpmPrune = true;

  postInstall = ''
    mv $out/lib/node_modules/pi-lsp-client $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules
    rm -f "$out/lib/${finalAttrs.pname}/node_modules/.package-lock.json"
  '';

  meta = {
    description = "Language Server Protocol integration for the Pi coding agent";
    homepage = "https://github.com/code-yeongyu/pi-lsp-client";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
