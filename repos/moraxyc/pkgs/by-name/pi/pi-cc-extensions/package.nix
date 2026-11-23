{
  lib,
  buildNpmPackage,
  importNpmLock,
  gitMinimal,
  nodejs,
  piBundleHook,
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

  nativeBuildInputs = [ piBundleHook ];

  piBundleFormat = "cjs";
  piBundleKeepNodeModules = true;
  # Keep @shikijs/cli external because shiki lazy-loads language/theme chunks
  # and WASM at runtime; @narumitw/pi-usage is an optional peer import.
  piBundleEsbuildFlags = [
    "--external:@shikijs/cli"
    "--external:@narumitw/pi-usage"
  ];
  piBundleCleanPaths = [
    "assets"
    "node_modules/grok-mermaid"
    "node_modules/jiti"
  ];

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
    rm -rf $out/lib/node_modules
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Claude Code-style TUI output with some personal touches and handy utilities for the Pi coding agent";
    homepage = "https://github.com/minuque/pi-cc-extensions";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
