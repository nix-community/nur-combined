{
  lib,
  stdenvNoCC,
  nodejs,
  piBundleHook,

  sources,
  source ? sources.pi-fast-resume,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname version src;
  __structuredAttrs = true;
  strictDeps = true;

  # Pi loads this extension directly; keep Node out of the runtime closure.
  dontPatchShebangs = true;

  nativeBuildInputs = [ piBundleHook ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}
    cp -r fast-resume.ts src package.json $out/lib/${finalAttrs.pname}

    runHook postInstall
  '';

  disallowedReferences = [ nodejs ];

  meta = {
    description = "Fast session picker for pi using partial file reads";
    homepage = "https://github.com/monotykamary/pi-fast-resume";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
