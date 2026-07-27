{
  lib,
  source,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  inherit (source) pname src;
  version = lib.removePrefix "V" source.version;

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    install -Dm444 fonts/static/Plangothic.ttc $_
  '';

  meta = with lib; {
    description = "CJKV Unified Extension Area - Glyph Supplementation + Source Han Sans";
    homepage = "https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic-Project";
    license = licenses.ofl;
  };
}
