{
  lib,
  buildNpmPackage,
  importNpmLock,
  esbuild,
  nodejs,

  sources,
  source ? sources.pi-lsp-client,
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

  npmInstallFlags = [ "--omit=dev" ];
  npmFlags = [ "--legacy-peer-deps" ];
  dontNpmBuild = true;

  postInstall = ''
    mv $out/lib/node_modules/pi-lsp-client $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules

    pkg="$out/lib/${finalAttrs.pname}"
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
      "$pkg/test" \
      "$pkg/node_modules" \
      "$pkg/.github" \
      "$pkg/AGENTS.md" \
      "$pkg/CHANGELOG.md" \
      "$pkg/README.md" \
      "$pkg/biome.json" \
      "$pkg/bun.lock" \
      "$pkg/tsconfig.json" \
      "$pkg/vitest.config.ts"
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Language Server Protocol integration for the Pi coding agent";
    homepage = "https://github.com/code-yeongyu/pi-lsp-client";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
