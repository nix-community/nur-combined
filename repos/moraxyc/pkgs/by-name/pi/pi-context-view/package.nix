{
  lib,
  stdenvNoCC,

  sources,
  source ? sources.pi-context-view,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}
    cp -r src package.json LICENSE $out/lib/${finalAttrs.pname}

    runHook postInstall
  '';

  meta = {
    description = "Context usage visualization and injection inspection for the Pi coding agent";
    homepage = "https://github.com/dimk90/pi-context-view";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
