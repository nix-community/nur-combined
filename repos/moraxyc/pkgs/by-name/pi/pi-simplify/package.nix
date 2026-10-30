{
  lib,
  stdenvNoCC,

  sources,
  source ? sources.pi-simplify,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname src;
  version = lib.removePrefix "pi-simplify-v" source.version;
  __structuredAttrs = true;
  strictDeps = true;

  postUnpack = ''
    sourceRoot+=/packages/pi-simplify
  '';

  postPatch = ''
    # Pi loads TypeScript directly, so no compiled entry point is needed.
    substituteInPlace package.json --replace-fail 'dist/index.js' 'src/index.ts'
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}
    cp -r src package.json $out/lib/${finalAttrs.pname}

    runHook postInstall
  '';

  meta = {
    description = "Code clarity, consistency, and maintainability review for the Pi coding agent";
    homepage = "https://github.com/MattDevy/pi-extensions/tree/main/packages/pi-simplify";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
