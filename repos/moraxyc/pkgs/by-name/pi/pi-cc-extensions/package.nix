{
  lib,
  buildNpmPackage,
  importNpmLock,
  gitMinimal,
  nodejs,
  writableTmpDirAsHomeHook,

  sources,
  source ? sources.pi-cc-extensions,
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
    "--legacy-peer-deps"
    "--ignore-scripts"
  ];
  dontNpmBuild = true;

  doCheck = true;
  nativeCheckInputs = [
    gitMinimal
    writableTmpDirAsHomeHook
  ];
  checkPhase = ''
    runHook preCheck

    mkdir -p "$HOME/.pi/agent"
    COLORTERM=truecolor \
    GIT_AUTHOR_NAME="Test" \
    GIT_AUTHOR_EMAIL="test@example.invalid" \
    GIT_COMMITTER_NAME="Test" \
    GIT_COMMITTER_EMAIL="test@example.invalid" \
      node --test tests/*.test.ts

    runHook postCheck
  '';

  postInstall = ''
    mv $out/lib/node_modules/pi-cc-extensions $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules "$out/lib/${finalAttrs.pname}/node_modules/.bin"
    rm -f "$out/lib/${finalAttrs.pname}/node_modules/.package-lock.json"
    grep -rlI '^#!/nix/store/' "$out/lib/${finalAttrs.pname}" | xargs -r sed -i '1s|^#!/nix/store/[^/]*/bin/node$|#!/usr/bin/env node|'
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Claude Code-style TUI output with some personal touches and handy utilities for the Pi coding agent";
    homepage = "https://github.com/minuque/pi-cc-extensions";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
