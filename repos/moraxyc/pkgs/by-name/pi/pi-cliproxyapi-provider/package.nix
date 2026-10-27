{
  lib,
  buildNpmPackage,
  importNpmLock,

  source ? sources.pi-cliproxyapi-provider,
  sources,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;

  patches = [ ./apiKeyCommand.patch ];

  npmDeps = importNpmLock {
    package = lib.importJSON source.extract."package.json";
    packageLock = lib.importJSON source.extract."package-lock.json";
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  dontNpmBuild = true;

  postInstall = ''
    cp -r $out/lib/node_modules/@router-for-me/pi-cliproxyapi-provider/. $out
    rm -rf $out/lib
  '';

  meta = {
    description = "Discovers models from CLIProxyAPI and registers them for use in pi";
    homepage = "https://github.com/router-for-me/pi-cliproxyapi-provider";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
