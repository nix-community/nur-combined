{
  lib,
  buildNpmPackage,
  importNpmLock,
  esbuild,
  makeWrapper,
  nodejs,
  nodejs-slim,
  versionCheckHook,

  sources,
  source ? sources.magic-context,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  patches = [ source.artifacts."npm-workspace.patch" ];

  npmDeps = importNpmLock source.npmDeps;
  npmConfigHook = importNpmLock.npmConfigHook;
  npmFlags = [ "--ignore-scripts" ];

  # The wrapper runs the bundle with nodejs-slim; a patched shebang would pull in full Node.
  dontPatchShebangs = true;

  nativeBuildInputs = [
    esbuild
    makeWrapper
  ];

  # Replaces upstream's `bun build`. Bun gives bundled CommonJS modules a `require`; the banner does that for esbuild.
  # Splitting keeps dynamic imports as real ESM: in esbuild's lazy wrappers the top-level await in shared/sqlite.ts is a syntax error.
  buildPhase = ''
    runHook preBuild

    esbuild packages/cli/src/index.ts \
      --bundle --platform=node --format=esm \
      --target=node${lib.versions.major nodejs-slim.version} \
      --external:node:sqlite \
      '--banner:js=import { createRequire as __createRequire } from "node:module"; const require = __createRequire(import.meta.url);' \
      --splitting --outdir=packages/cli/dist --entry-names=[name]

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # The CLI reads its version from ../package.json relative to the bundle.
    mkdir -p $out/lib/${finalAttrs.pname}
    cp -r packages/cli/{package.json,dist} $out/lib/${finalAttrs.pname}/
    makeWrapper ${lib.getExe nodejs-slim} $out/bin/magic-context \
      --add-flags $out/lib/${finalAttrs.pname}/dist/index.js

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Setup, doctor and migration CLI for Magic Context";
    homepage = "https://github.com/cortexkit/magic-context";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "magic-context";
  };
})
