{ stdenvNoCC
, lib
, sources
, ...
} @ args:

let
  package = P1_variant: stdenvNoCC.mkDerivation rec {
    inherit (sources.plangothic-fonts) pname version src;
    installPhase = ''
      mkdir -p $out/share/fonts/truetype/
      cp "PlangothicP1-Regular (${P1_variant}).ttf" $out/share/fonts/truetype/
      cp "PlangothicP2-Regular.ttf" $out/share/fonts/truetype/
    '';

    meta = with lib; {
      description = "Plangothic Project";
      homepage = "https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic";
      license = licenses.ofl;
    };
  };
in
{
  allideo = package "allideo";
  fallback = package "fallback";
}
