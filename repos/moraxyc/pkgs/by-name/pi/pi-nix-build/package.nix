{
  lib,
  stdenvNoCC,
  nodejs,
  piBundleHook,

  sources,
  source ? sources.pi-nix-build,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  dontPatchShebangs = true;

  nativeBuildInputs = [ piBundleHook ];

  piBundleEntries = [ "./src/index.ts" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}
    cp -r src package.json LICENSE $out/lib/${finalAttrs.pname}

    runHook postInstall
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Pi extension for Nix builds with live progress";
    homepage = "https://github.com/Moraxyc/pi-nix-build";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
