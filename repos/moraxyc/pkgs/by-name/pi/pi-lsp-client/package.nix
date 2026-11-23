{
  lib,
  buildNpmPackage,
  importNpmLock,
  nodejs,
  piBundleHook,

  sources,
  source ? sources.pi-lsp-client,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  npmDeps = importNpmLock source.npmDeps;
  npmConfigHook = importNpmLock.npmConfigHook;

  # Pi loads this extension directly; keep Node out of the runtime closure.
  dontPatchShebangs = true;

  nativeBuildInputs = [ piBundleHook ];

  piBundleFormat = "cjs";

  npmInstallFlags = [ "--omit=dev" ];
  npmFlags = [ "--legacy-peer-deps" ];
  dontNpmBuild = true;

  postInstall = ''
    mv $out/lib/node_modules/pi-lsp-client $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Language Server Protocol integration for the Pi coding agent";
    homepage = "https://github.com/code-yeongyu/pi-lsp-client";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
