{
  stdenvNoCC,
  lib,
  sources,
  ...
}:
let
  package = stdenvNoCC.mkDerivation rec {
    pname = "plangothic-fonts";
    inherit (sources.plangothic-fonts) version src;
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/fonts/truetype/
      cp "fonts/static/PlangothicP1-Regular.ttf" $out/share/fonts/truetype/
      cp "fonts/static/PlangothicP2-Regular.ttf" $out/share/fonts/truetype/

      runHook postInstall
    '';

    meta = {
      maintainers = with lib.maintainers; [ xddxdd ];
      description = "Plangothic Project";
      homepage = "https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic_Project";
      license = lib.licenses.ofl;
    };
  };
in
package
// {
  allideo = package;
  fallback = package;
}
