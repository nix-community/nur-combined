{
  lib,
  buildNpmPackage,
  importNpmLock,
  nodejs,
  piBundleHook,
  tmux,

  sources,
  source ? sources.pi-live-terminal,
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
  nativeCheckInputs = [ tmux ];
  checkPhase = ''
    runHook preCheck

    npm test

    runHook postCheck
  '';

  # Pi provides all peerDependencies at runtime and the package has no runtime dependencies.
  postInstall = ''
    mv $out/lib/node_modules/pi-live-terminal $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Pi extension that runs commands in tmux and displays a live terminal widget";
    homepage = "https://github.com/tanishqkancharla/pi-live-terminal";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
