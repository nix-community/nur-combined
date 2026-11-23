{
  lib,
  buildNpmPackage,
  importNpmLock,
  nodejs,
  piBundleHook,

  source ? sources.pi-cliproxyapi-provider,
  sources,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  patches = [ ./apiKeyCommand.patch ];

  npmDeps = importNpmLock source.npmDeps;
  npmConfigHook = importNpmLock.npmConfigHook;

  # Pi loads this extension directly; keep Node out of the runtime closure.
  dontPatchShebangs = true;

  nativeBuildInputs = [ piBundleHook ];

  npmFlags = [
    "--omit=dev"
    "--legacy-peer-deps"
    "--ignore-scripts"
  ];
  dontNpmBuild = true;
  dontNpmPrune = true;

  # npmInstallHook deletes empty `node_modules` and then fails on `cp -r node_modules`.
  preInstall = ''
    mkdir -p "$out/lib/node_modules/@router-for-me/pi-cliproxyapi-provider/node_modules"
  '';

  postInstall = ''
    mv $out/lib/node_modules/@router-for-me/pi-cliproxyapi-provider $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Discovers models from CLIProxyAPI and registers them for use in pi";
    homepage = "https://github.com/router-for-me/pi-cliproxyapi-provider";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
