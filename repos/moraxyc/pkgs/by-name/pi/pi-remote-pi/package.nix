{
  lib,
  stdenvNoCC,
  fetchPnpmDeps,
  makeWrapper,
  nodejs,
  nodejs-slim,
  pnpmConfigHook,
  pnpm_11,
  typescript,

  sources,
  source ? sources.pi-remote-pi,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  sourceRoot = "${finalAttrs.src.name}/pi-extension";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      pnpmInstallFlags
      ;
    pnpm = pnpm_11;
    fetcherVersion = 5;
    hash = source.pnpmDepsHash;
  };
  pnpmInstallFlags = [
    "--prod"
    "--no-optional"
  ];

  dontPatchShebangs = true;

  nativeBuildInputs = [
    makeWrapper
    nodejs
    pnpm_11
    pnpmConfigHook
    typescript
  ];

  buildPhase = ''
    runHook preBuild

    tsc -p tsconfig.json --noCheck --types "" --declaration false --sourceMap false

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname} $out/bin
    cp -r dist skills service-templates docs package.json LICENSE node_modules \
      $out/lib/${finalAttrs.pname}/

    rm -rf "$out/lib/${finalAttrs.pname}/node_modules/.bin" \
      "$out/lib/${finalAttrs.pname}/node_modules/.modules.yaml" \
      "$out/lib/${finalAttrs.pname}/node_modules/.pnpm/lock.yaml"
    grep -rlI '^#!/nix/store/' "$out/lib/${finalAttrs.pname}" \
      | xargs -r sed -i '1s|^#!/nix/store/[^/]*/bin/node$|#!/usr/bin/env node|'

    chmod +x \
      "$out/lib/${finalAttrs.pname}/dist/index.js" \
      "$out/lib/${finalAttrs.pname}/dist/bin/supervisord.js"

    makeWrapper ${lib.getExe nodejs-slim} $out/bin/remote-pi \
      --add-flags "$out/lib/${finalAttrs.pname}/dist/index.js"
    makeWrapper ${lib.getExe nodejs-slim} $out/bin/pi-supervisord \
      --add-flags "$out/lib/${finalAttrs.pname}/dist/bin/supervisord.js"

    runHook postInstall
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Mobile remote control and local agent mesh extension for the Pi coding agent";
    homepage = "https://github.com/jacobaraujo7/remote_pi/tree/main/pi-extension";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "remote-pi";
  };
})
