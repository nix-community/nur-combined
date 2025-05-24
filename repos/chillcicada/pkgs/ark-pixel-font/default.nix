{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

let
  buildHashes = builtins.fromJSON (builtins.readFile ./hashes.json);

  ark-pixel-font =
    {
      fontSize,
      fontStyle,
      fontFormat,
    }:

    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "ark-pixel-font-${fontSize}-${fontStyle}-${fontFormat}";
      version = "2025.03.14";

      src = fetchurl {
        url = "https://github.com/TakWolf/ark-pixel-font/releases/download/${finalAttrs.version}/${finalAttrs.pname}-v${finalAttrs.version}.zip";
        hash = buildHashes."${finalAttrs.pname}";
      };

      sourceRoot = ".";
      nativeBuildInputs = [ unzip ];

      installPhase = ''
        find . -name '*.ttf'   -exec install -Dt $out/share/fonts/truetype {} \;
        find . -name '*.ttc'   -exec install -Dt $out/share/fonts/truetype {} \;
        find . -name '*.otf'   -exec install -Dt $out/share/fonts/opentype {} \;
        find . -name '*.otc'   -exec install -Dt $out/share/fonts/opentype {} \;
        find . -name '*.woff2' -exec install -Dt $out/share/fonts/woff2 {} \;
        find . -name '*.bdf'   -exec install -Dt $out/share/fonts/misc {} \;
        find . -name '*.pcf'   -exec install -Dt $out/share/fonts/misc {} \;
      '';

      meta = {
        homepage = "https://github.com/TakWolf/ark-pixel-font";
        description = ''
          ark pixel font ${fontSize} ${fontStyle} ${fontFormat}, Open Source Pan-CJK Pixel Font
        '';
        license = lib.licenses.ofl;
        platforms = lib.platforms.all;
        maintainers = with lib.maintainers; [ chillcicada ];
      };
    });
in

lib.listToAttrs (
  map
    (
      variant:
      let
        fontSize = variant.fontSize;
        fontStyle = variant.fontStyle;
        fontFormat = variant.fontFormat;
      in
      {
        name = "${fontSize}-${fontStyle}-${fontFormat}";
        value = ark-pixel-font { inherit fontSize fontStyle fontFormat; };
      }
    )
    (
      lib.cartesianProduct {
        fontSize = [
          "16px"
          "12px"
          "10px"
        ];
        fontStyle = [
          "proportional"
          "monospaced"
        ];
        fontFormat = [
          "ttf"
          "ttc"
          "otc"
          "otf"
          "woff2"
          "bdf"
          "pcf"
        ];
      }
    )
)
