{
  source,
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  inherit (source) pname src;
  version = "0-unstable-${source.date}";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/PaperWM.spoon
    cp -r . $out/PaperWM.spoon

    runHook postInstall
  '';

  meta = {
    description = "Tiled scrollable window manager for MacOS";
    homepage = "https://github.com/mogenson/PaperWM.spoon";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
  };
})
