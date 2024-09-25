{
  stdenvNoCC,
  lib,
  sources,
  ...
}:
let
  package =
    P1_variant:
    stdenvNoCC.mkDerivation rec {
      pname = "plangothic-fonts-${P1_variant}";
      inherit (sources.plangothic-fonts) version src;
      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/fonts/truetype/
        cp "PlangothicP1-Regular (${P1_variant}).ttf" $out/share/fonts/truetype/
        cp "PlangothicP2-Regular.ttf" $out/share/fonts/truetype/

        runHook postInstall
      '';

      meta = with lib; {
        maintainers = with lib.maintainers; [ xddxdd ];
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
