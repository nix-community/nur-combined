{
  lib,
  stdenvNoCC,
  nodejs,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  piBundleHook,
  writableTmpDirAsHomeHook,

  sources,
  source ? sources.pi-ask,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  dontPatchShebangs = true;

  nativeBuildInputs = [
    pnpm_10
    pnpmConfigHook
    piBundleHook
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 5;
    hash = source.pnpmDepsHash;
  };

  dontBuild = true;

  piBundleSrcDir = ".";
  piBundleKeepSources = true;

  doCheck = true;
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];
  checkPhase = ''
    runHook preCheck

    pnpm run typecheck
    pnpm test

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}/docs
    cp -r skills package.json LICENSE $out/lib/${finalAttrs.pname}/
    cp docs/configuration.md docs/contract.md docs/remote-events.md $out/lib/${finalAttrs.pname}/docs/

    runHook postInstall
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Interactive clarification flows for Pi coding agent";
    homepage = "https://github.com/eko24ive/pi-ask";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
