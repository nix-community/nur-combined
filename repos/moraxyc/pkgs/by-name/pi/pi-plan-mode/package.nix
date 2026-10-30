{
  lib,
  stdenvNoCC,

  sources,
  source ? sources.pi-plan-mode,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}
    cp plan-mode.ts package.json $out/lib/${finalAttrs.pname}

    runHook postInstall
  '';

  meta = {
    description = "Read-only plan mode with plan file editing for the Pi coding agent";
    homepage = "https://github.com/qmx/pi-plan-mode";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
