{
  lib,
  buildNpmPackage,
  importNpmLock,
  makeWrapper,
  nodejs,
  nodejs-slim,

  sources,
  source ? sources.pi-web-access,
}:

buildNpmPackage (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  # Full Node is needed for npm at build time; wrap the CLI with nodejs-slim so npm/corepack stay out of runtime closure.
  dontPatchShebangs = true;

  npmDeps = importNpmLock source.npmDeps;
  npmConfigHook = importNpmLock.npmConfigHook;

  nativeBuildInputs = [ makeWrapper ];

  npmFlags = [ "--legacy-peer-deps" ];

  postPatch = ''
    substituteInPlace scripts/build.js \
      --replace-fail 'format: "esm"' 'format: "esm", minify: true'
  '';

  postBuild = ''
    node scripts/pi-extensions-dist.js dist
  '';

  postInstall = ''
    mv $out/lib/node_modules/pi-web-access $out/lib/${finalAttrs.pname}
    rm -rf $out/lib/node_modules "$out/lib/${finalAttrs.pname}/node_modules/.bin"
    rm -f "$out/lib/${finalAttrs.pname}/node_modules/.package-lock.json"
    # Pi loads the prebuilt dist bundle; TypeScript sources and media are unused.
    rm $out/lib/${finalAttrs.pname}/{*.ts,banner.png,pi-web-fetch-demo.mp4,SECURITY.md}
    grep -rlI '^#!/nix/store/' "$out/lib/${finalAttrs.pname}" | xargs -r sed -i '1s|^#!/nix/store/[^/]*/bin/node$|#!/usr/bin/env node|'

    rm -f $out/bin/pi-web-access-mcp
    makeWrapper ${lib.getExe nodejs-slim} $out/bin/pi-web-access-mcp \
      --add-flags "$out/lib/${finalAttrs.pname}/dist/mcp-cli.js"
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Web search and content extraction for the Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-web-access";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "pi-web-access-mcp";
  };
})
