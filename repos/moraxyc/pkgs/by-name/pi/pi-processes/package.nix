{
  lib,
  stdenvNoCC,
  nodejs,
  pnpm_11,
  fetchPnpmDeps,
  pnpmConfigHook,

  sources,
  source ? sources.pi-processes,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    pnpm_11
    pnpmConfigHook
  ];

  # nix-update auto
  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_11;
    fetcherVersion = 5;
    pnpmInstallFlags = finalAttrs.pnpmInstallFlags;
    hash = "sha256-hBoaGMQc8bmEB8gfLRfNIGMzKy+rhM80DlDItaiqEDs=";
  };
  # Pi supplies the optional peer dependencies of the utility packages.
  pnpmInstallFlags = [
    "--prod"
    "--no-optional"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}
    cp -r extensions skills src schema.json package.json node_modules $out/lib/${finalAttrs.pname}

    runHook postInstall
  '';

  meta = {
    description = "Background process management for the Pi coding agent";
    homepage = "https://github.com/aliou/pi-processes";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
