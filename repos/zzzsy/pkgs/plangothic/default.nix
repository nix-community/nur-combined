{
  source,
  lib,
  stdenvNoCC,
  fallback ? true,
}:

stdenvNoCC.mkDerivation {
  inherit (source) pname src;
  version = lib.strings.removePrefix "V" source.version;

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    mv "PlangothicP2-Regular.ttf" "PlangothicP1-Regular (${
      if fallback then "fallback" else "allideo"
    }).ttf" $_
  '';

  meta = with lib; {
    description = "CJKV Unified Extension Area - Glyph Supplementation + Source Han Sans";
    homepage = "https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic-Project";
    license = licenses.ofl;
  };
}
