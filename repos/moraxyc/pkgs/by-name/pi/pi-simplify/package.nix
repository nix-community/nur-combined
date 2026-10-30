{
  lib,
  stdenvNoCC,
  typescript,

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

  nativeBuildInputs = [ typescript ];

  # Type checking needs the Pi peer dependencies, which the host provides at runtime.
  buildPhase = ''
    runHook preBuild

    tsc -p tsconfig.build.json --noCheck --composite false --declaration false --declarationMap false --sourceMap false

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/${finalAttrs.pname}
    cp -r dist package.json $out/lib/${finalAttrs.pname}

    runHook postInstall
  '';

  meta = {
    description = "Code clarity, consistency, and maintainability review for the Pi coding agent";
    homepage = "https://github.com/MattDevy/pi-extensions/tree/main/packages/pi-simplify";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
