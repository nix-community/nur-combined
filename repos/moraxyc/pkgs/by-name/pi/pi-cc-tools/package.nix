{
  lib,
  buildNpmPackage,
  importNpmLock,
  nodejs,

  sources,
  source ? sources.pi-cc-tools,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  npmDeps = importNpmLock source.npmDeps;
  npmConfigHook = importNpmLock.npmConfigHook;

  # Pi loads this extension directly; keep Node out of the runtime closure.
  dontPatchShebangs = true;

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
    rm -rf $out/lib/node_modules "$out/lib/${finalAttrs.pname}/node_modules/.bin"
    rm -f "$out/lib/${finalAttrs.pname}/node_modules/.package-lock.json"
    grep -rlI '^#!/nix/store/' "$out/lib/${finalAttrs.pname}" | xargs -r sed -i '1s|^#!/nix/store/[^/]*/bin/node$|#!/usr/bin/env node|'
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Claude Code style UI for pi: one-line tool groups, syntax-highlighted diffs, an activity spinner, and colors from your terminal theme";
    homepage = "https://github.com/FammasMaz/pi-cc-tools";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
