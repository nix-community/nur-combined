{
  lib,
  stdenvNoCC,
  nodejs,
  pnpm_11,
  fetchPnpmDeps,
  pnpmConfigHook,
  piBundleHook,

  sources,
  source ? sources.pi-processes,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    pnpm_11
    pnpmConfigHook
    piBundleHook
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 5;
    pnpmInstallFlags = finalAttrs.pnpmInstallFlags;
    hash = source.pnpmDepsHash;
  };
  # Pi supplies the optional peer dependencies of the utility packages.
  pnpmInstallFlags = [
    "--prod"
    "--no-optional"
  ];

  dontBuild = true;

  piBundleFormat = "cjs";
  piBundleSrcDir = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}
    cp -r skills schema.json package.json $out/lib/${finalAttrs.pname}

    runHook postInstall
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Background process management for the Pi coding agent";
    homepage = "https://github.com/aliou/pi-processes";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
