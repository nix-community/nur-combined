{
  lib,
  stdenvNoCC,
  nodejs,
  piBundleHook,

  source ? sources.pi-token-speed,
  sources,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  dontPatchShebangs = true;

  nativeBuildInputs = [ piBundleHook ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}
    cp -r src package.json LICENSE.md $out/lib/${finalAttrs.pname}

    runHook postInstall
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Pi extension to measure tokens per second via sliding window";
    homepage = "https://github.com/gsanhueza/pi-token-speed";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
