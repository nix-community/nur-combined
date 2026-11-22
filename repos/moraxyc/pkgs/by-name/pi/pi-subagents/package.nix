{
  lib,
  buildNpmPackage,
  importNpmLock,
  gitMinimal,
  nodejs,
  esbuild,
  writableTmpDirAsHomeHook,

  sources,
  source ? sources.pi-subagents,
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

    npm run typecheck
    # test/env.test.ts checks detectEnv() against process.cwd() as a git repo.
    git init -q
    npm test
    rm -rf .git

    runHook postCheck
  '';

  postInstall = ''
    mv $out/lib/node_modules/@tintinweb/pi-subagents $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules

    pkg="$out/lib/${finalAttrs.pname}"
    # Bundle into a single CJS entry so jiti skips multi-file TS resolution;
    # anchor __import_meta_url two levels below the package root so ../../skills resolves.
    esbuild "$pkg/src/index.ts" \
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
      --define:import.meta.url=__import_meta_url \
      --banner:js='const __import_meta_url = require("node:url").pathToFileURL(require("node:path").join(__dirname, "workflow", "index.cjs")).href;' \
      --outfile="$pkg/dist/index.cjs"

    node -e '
      const fs = require("node:fs");
      const p = process.argv[1];
      const pkg = JSON.parse(fs.readFileSync(p, "utf8"));
      pkg.pi.extensions = ["./dist/index.cjs"];
      fs.writeFileSync(p, JSON.stringify(pkg, null, 2) + "\n");
    ' "$pkg/package.json"

    rm -rf \
      "$pkg/src" \
      "$pkg/node_modules" \
      "$pkg/docs" \
      "$pkg/examples" \
      "$pkg"/README*.md \
      "$pkg/CHANGELOG.md" \
      "$pkg/CONTRIBUTING.md" \
      "$pkg/SECURITY.md"
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Claude Code-like subagents and workflow orchestration for the Pi coding agent";
    homepage = "https://github.com/tintinweb/pi-subagents";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
