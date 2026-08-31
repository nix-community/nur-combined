{
  fetchFromGitHub,
  stdenv,
  lib,
  ...
}:
let
  package = stdenv.mkDerivation (finalAttrs: {
    pname = "plangothic-fonts";
    version = "2.9.5795";
    src = fetchFromGitHub {
      owner = "Fitzgerald-Porthmouth-Koenigsegg";
      repo = "Plangothic_Project";
      tag = "V${finalAttrs.version}";
      hash = "sha256-7Y18HcCvwWTX5CWguLuo6Z+l/tcTfKmblZ5st/TL6TI=";
    };
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/fonts/truetype/
      cp "fonts/static/PlangothicP1-Regular.ttf" $out/share/fonts/truetype/
      cp "fonts/static/PlangothicP2-Regular.ttf" $out/share/fonts/truetype/

      runHook postInstall
    '';

    meta = {
      changelog = "https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic_Project/releases/tag/V${finalAttrs.version}";
      maintainers = with lib.maintainers; [ xddxdd ];
      description = "Plangothic Project";
      homepage = "https://github.com/Fitzgerald-Porthmouth-Koenigsegg/Plangothic_Project";
      license = lib.licenses.ofl;
    };
  });
in
package
// {
  allideo = package;
  fallback = package;
}
