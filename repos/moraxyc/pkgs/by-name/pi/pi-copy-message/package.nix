{
  lib,
  buildNpmPackage,
  importNpmLock,
  nodejs,
  piBundleHook,

  sources,
  source ? sources.pi-copy-message,
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

  piBundleEntries = [ "./extensions/copy-message.ts" ];

  npmFlags = [ "--ignore-scripts" ];
  dontNpmBuild = true;
  dontNpmPrune = true;

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    npm run typecheck
    # tests/quality-harness.test.ts spawns the prebuilt oxlint binary from node_modules.
    node --test tests/copy-message.test.ts tests/native-ui.test.ts

    runHook postCheck
  '';

  postInstall = ''
    mv $out/lib/node_modules/pi-copy-message $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Pi extension with a searchable TUI picker for copying raw session messages";
    homepage = "https://github.com/fitchmultz/pi-copy-message";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
