{
  lib,
  buildNpmPackage,
  importNpmLock,
  esbuild,
  makeWrapper,
  nodejs_24,
  nodejs-slim_24,

  sources,
  source ? sources.lm-detector,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  nodejs = nodejs_24;

  # Drops the monorepo workspaces, so the lock below is self-contained.
  patches = [ source.artifacts."fix-workspace.patch" ];

  npmDeps =
    let
      lock = lib.importJSON source.artifacts."package-lock.json";
    in
    importNpmLock {
      package = removeAttrs lock.packages."" [
        "devDependencies"
        "peerDependencies"
      ];
      packageLock = lock // {
        packages = lib.filterAttrs (_: package: !(package.dev or false)) lock.packages;
      };
    };
  npmConfigHook = importNpmLock.npmConfigHook;

  postPatch = ''
    cp ${source.artifacts."package-lock.json"} package-lock.json
  '';

  npmFlags = [
    "--omit=dev"
    "--ignore-scripts"
  ];
  dontNpmBuild = true;

  nativeBuildInputs = [
    esbuild
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild

    # `shared/` is a workspace package in upstream; link it where its imports expect it.
    mkdir -p node_modules/@fingerpoint
    ln -s ../../shared node_modules/@fingerpoint/shared

    # Same data checks and public metadata as upstream `web/scripts/sync-data.ts`, run under Node.
    esbuild web/scripts/sync-data.ts \
      --bundle --format=esm --platform=node --target=node24 \
      --external:ml-matrix --external:opentype.js \
      --outfile=sync-data.mjs
    node sync-data.mjs

    # Same layout as upstream `cli/build.ts`, with Node as the shebang target.
    mkdir -p dist/fpd/{bin,data}
    esbuild cli/fpd.ts cli/bank-worker.ts cli/retrain-worker.ts \
      --bundle --format=esm --platform=node --target=node24 --splitting \
      --jsx=automatic \
      --outdir=dist/fpd/bin --entry-names='[name]' \
      --define:FPD_BUILD_VERSION='"${finalAttrs.version}"' \
      --external:ink --external:react --external:terminal-link

    sed -i '1s|^#!/usr/bin/env bun$|#!/usr/bin/env node|' dist/fpd/bin/fpd.js
    chmod 755 dist/fpd/bin/fpd.js

    cp web/.generated/unified_bank.json dist/fpd/data/unified_bank.json
    cp data/shared_detector.bin dist/fpd/data/shared_detector.bin
    cp data/tokenizer_bank.json dist/fpd/data/tokenizer_bank.json
    cp shared/prompt-font.otf dist/fpd/bin/prompt-font.otf
    cp cli/README.md dist/fpd/README.md
    cp LICENSE dist/fpd/LICENSE

    node -e '
      const fs = require("node:fs");
      const manifest = JSON.parse(fs.readFileSync("cli/npm-package.json", "utf8"));
      const dependencies = {};
      for (const name of ["ink", "react", "terminal-link"]) {
        dependencies[name] = JSON.parse(fs.readFileSync("node_modules/" + name + "/package.json", "utf8")).version;
      }
      fs.writeFileSync(
        "dist/fpd/package.json",
        JSON.stringify({ ...manifest, version: process.argv[1], dependencies }, null, 2) + "\n",
      );
    ' "${finalAttrs.version}"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    appDir=$out/lib/node_modules/lmfpd
    mkdir -p "$appDir" "$out/bin"
    cp -r dist/fpd/. "$appDir/"
    cp -r node_modules "$appDir/"
    # The workspace link points at the build tree and is already bundled.
    rm -rf "$appDir/node_modules/@fingerpoint"

    makeWrapper ${lib.getExe nodejs-slim_24} $out/bin/fpd \
      --add-flags "$appDir/bin/fpd.js"

    runHook postInstall
  '';

  meta = {
    description = "Identify the large language model behind an API from a few hundred first-instinct integers";
    homepage = "https://github.com/Ikaleio/lm-detector";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "fpd";
  };
})
