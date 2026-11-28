{
  lib,
  buildNpmPackage,
  importNpmLock,
  nodejs,
  piBundleHook,
  writableTmpDirAsHomeHook,

  sources,
  source ? sources.pi-btw,
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

  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;
  dontNpmPrune = true;

  doCheck = true;
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];
  checkPhase = ''
    runHook preCheck

    npm run typecheck
    npm test

    runHook postCheck
  '';

  postInstall = ''
    mv $out/lib/node_modules/pi-btw $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Pi extension for parallel side conversations with /btw";
    homepage = "https://github.com/dbachelder/pi-btw";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
