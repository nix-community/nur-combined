{
  lib,
  buildNpmPackage,
  importNpmLock,
  esbuild,
  nodejs,
  writableTmpDirAsHomeHook,

  sources,
  source ? sources.pi-working-activity,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  npmDeps =
    let
      lock = lib.importJSON source.artifacts."package-lock.json";
    in
    importNpmLock {
      package = lock.packages."";
      packageLock = lock;
    };
  npmConfigHook = importNpmLock.npmConfigHook;

  # Pi loads this extension directly; keep Node out of the runtime closure.
  dontPatchShebangs = true;

  nativeBuildInputs = [ esbuild ];

  postPatch = ''
    cp ${source.artifacts."package-lock.json"} package-lock.json
  '';

  npmFlags = [
    "--legacy-peer-deps"
    "--ignore-scripts"
  ];
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

  # npmInstallHook deletes empty `node_modules` and then fails on `cp -r node_modules`.
  preInstall = ''
    mkdir -p "$out/lib/node_modules/pi-working-activity/node_modules"
  '';

  postInstall = ''
    mv $out/lib/node_modules/pi-working-activity $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules

    pkg="$out/lib/${finalAttrs.pname}"
    # Bundle into a single ESM entry so jiti skips TypeScript compilation while preserving the default export.
    esbuild "$pkg/extensions/index.ts" \
      --bundle \
      --platform=node \
      --target=node${lib.versions.major nodejs.version} \
      --format=esm \
      --external:@earendil-works/\* \
      --external:@mariozechner/\* \
      --external:typebox \
      --external:typebox/\* \
      --external:@sinclair/typebox \
      --external:@sinclair/typebox/\* \
      --outfile="$pkg/dist/index.mjs"

    node -e '
      const fs = require("node:fs");
      const p = process.argv[1];
      const pkg = JSON.parse(fs.readFileSync(p, "utf8"));
      pkg.pi.extensions = ["./dist/index.mjs"];
      fs.writeFileSync(p, JSON.stringify(pkg, null, 2) + "\n");
    ' "$pkg/package.json"

    rm -rf \
      "$pkg/extensions" \
      "$pkg/node_modules" \
      "$pkg"/README*.md
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Lively working-line extension for the Pi coding agent";
    homepage = "https://github.com/ccch1mneyyy/working-activity";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
