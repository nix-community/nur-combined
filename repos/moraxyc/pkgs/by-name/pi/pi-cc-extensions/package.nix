{
  lib,
  buildNpmPackage,
  importNpmLock,
  gitMinimal,
  nodejs,
  esbuild,
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

  nativeBuildInputs = [ esbuild ];

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

    pkg="$out/lib/${finalAttrs.pname}"
    # Keep @shikijs/cli external because shiki lazy-loads language/theme chunks
    # and WASM at runtime; @narumitw/pi-usage is an optional peer import.
    esbuild "$pkg/extensions/index.ts" \
      --bundle \
      --platform=node \
      --target=node${lib.versions.major nodejs.version} \
      --format=cjs \
      --external:@earendil-works/\* \
      --external:@mariozechner/\* \
      --external:typebox \
      --external:typebox/\* \
      --external:@sinclair/typebox \
      --external:@sinclair/typebox/\* \
      --external:@shikijs/cli \
      --external:@narumitw/pi-usage \
      --outfile="$pkg/dist/index.cjs"

    node -e '
      const fs = require("node:fs");
      const p = process.argv[1];
      const pkg = JSON.parse(fs.readFileSync(p, "utf8"));
      pkg.pi.extensions = ["./dist/index.cjs"];
      fs.writeFileSync(p, JSON.stringify(pkg, null, 2) + "\n");
    ' "$pkg/package.json"

    rm -rf \
      "$pkg/extensions" \
      "$pkg/assets" \
      "$pkg"/README*.md \
      "$pkg/CHANGELOG.md" \
      "$pkg/node_modules/grok-mermaid" \
      "$pkg/node_modules/jiti" \
      "$pkg/node_modules/@types"
    { grep -rlI '^#!/nix/store/' "$pkg" || true; } | xargs -r sed -i '1s|^#!/nix/store/[^/]*/bin/node$|#!/usr/bin/env node|'
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Claude Code-style TUI output with some personal touches and handy utilities for the Pi coding agent";
    homepage = "https://github.com/minuque/pi-cc-extensions";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
