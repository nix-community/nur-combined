{
  lib,
  buildNpmPackage,
  importNpmLock,
  makeWrapper,
  nodejs,
  nodejs-slim,
  typescript,

  sources,
  source ? sources.pi-mcp-adapter,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) src version pname;
  __structuredAttrs = true;
  strictDeps = true;

  # Full Node is needed for npm at build time; wrap the CLI with nodejs-slim so npm/corepack stay out of runtime closure.
  dontPatchShebangs = true;

  npmDeps = importNpmLock source.npmDeps;
  npmConfigHook = importNpmLock.npmConfigHook;

  nativeBuildInputs = [
    makeWrapper
    typescript
  ];
  npmInstallFlags = [ "--omit=dev" ];
  npmFlags = [ "--legacy-peer-deps" ];

  # Rebuild the committed dist/ that cli.js and the public subpath exports load.
  postPatch = ''
    rm -rf dist
  '';

  # Type checking needs the Pi dev dependencies, which the host provides at runtime.
  buildPhase = ''
    runHook preBuild

    tsc -p tsconfig.public.json --noCheck

    runHook postBuild
  '';
  npmPackFlags = [ "--ignore-scripts" ];

  postInstall = ''
    mv $out/lib/node_modules/pi-mcp-adapter $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules "$out/lib/${finalAttrs.pname}/node_modules/.bin"
    # Drop optional native/JAR recheck backends (52 MiB); recheck falls back to its built-in pure-JS checker.
    rm -rf "$out/lib/${finalAttrs.pname}/node_modules"/recheck-{jar,linux-*,macos-*,windows-*}
    rm -f "$out/lib/${finalAttrs.pname}/node_modules/.package-lock.json"
    grep -rlI '^#!/nix/store/' "$out/lib/${finalAttrs.pname}" | xargs -r sed -i '1s|^#!/nix/store/[^/]*/bin/node$|#!/usr/bin/env node|'

    rm -f $out/bin/pi-mcp-adapter
    makeWrapper ${lib.getExe nodejs-slim} $out/bin/pi-mcp-adapter \
      --add-flags "$out/lib/${finalAttrs.pname}/cli.js"
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "MCP adapter for Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-mcp-adapter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
