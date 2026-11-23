{
  lib,
  buildNpmPackage,
  importNpmLock,
  nodejs,
  piBundleHook,

  sources,
  source ? sources.pi-cc-tools,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  patches = [ ./preserve-tool-exposure.patch ];

  npmDeps = importNpmLock source.npmDeps;
  npmConfigHook = importNpmLock.npmConfigHook;

  # Pi loads this extension directly; keep Node out of the runtime closure.
  dontPatchShebangs = true;

  nativeBuildInputs = [ piBundleHook ];

  piBundleKeepNodeModules = true;
  piBundleEsbuildFlags = [ "--external:@shikijs/cli" ];
  piBundleCleanPaths = [ "node_modules/diff" ];

  npmFlags = [
    "--omit=dev"
    "--legacy-peer-deps"
    "--ignore-scripts"
  ];
  dontNpmBuild = true;
  dontNpmPrune = true;

  # Integration tests import @earendil-works/pi-coding-agent and @earendil-works/pi-tui from devDependencies.
  doCheck = true;
  checkPhase = ''
    runHook preCheck

    node --experimental-strip-types --test \
      scripts/bash-command.test.ts \
      scripts/bash-file-edit.test.ts

    runHook postCheck
  '';

  postInstall = ''
    mv $out/lib/node_modules/pi-claude-code-ui $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Claude Code style UI for pi: one-line tool groups, syntax-highlighted diffs, an activity spinner, and colors from your terminal theme";
    homepage = "https://github.com/FammasMaz/pi-cc-tools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
