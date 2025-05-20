{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

let
  buildHashes = builtins.fromJSON (builtins.readFile ./hashes.json);

  fusion-pixel-font =
    {
      fontSize,
      fontStyle,
      fontType,
    }:

    stdenvNoCC.mkDerivation (finalAttrs: {
      pname = "fusion-pixel-font-${fontSize}-${fontStyle}-${fontType}";
      version = "2025.03.14";

      src = fetchurl {
        url = "https://github.com/TakWolf/fusion-pixel-font/releases/download/${finalAttrs.version}/${finalAttrs.pname}-v${finalAttrs.version}.zip";
        hash = buildHashes."${finalAttrs.pname}";
      };

      sourceRoot = ".";
      nativeBuildInputs = [ unzip ];

      installPhase = ''
        mkdir -p $out/share/fonts/{truetype,opentype,woff2,misc}

        find . -name '*.ttf'   -exec install -Dt $out/share/fonts/truetype {} \;
        find . -name '*.ttc'   -exec install -Dt $out/share/fonts/truetype {} \;
        find . -name '*.otf'   -exec install -Dt $out/share/fonts/opentype {} \;
        find . -name '*.otc'   -exec install -Dt $out/share/fonts/opentype {} \;
        find . -name '*.woff2' -exec install -Dt $out/share/fonts/woff2 {} \;
        find . -name '*.bdf'   -exec install -Dt $out/share/fonts/misc {} \;
        find . -name '*.pcf'   -exec install -Dt $out/share/fonts/misc {} \;
      '';

      meta = {
        homepage = "https://github.com/TakWolf/fusion-pixel-font";
        description = "Fusion Pixel Font";
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
        fontType = variant.fontType;
      in
      {
        name = "${fontSize}-${fontStyle}-${fontType}";
        value = fusion-pixel-font { inherit fontSize fontStyle fontType; };
      }
    )
    (
      lib.cartesianProduct {
        fontSize = [
          "12px"
          "10px"
          "8px"
        ];
        fontStyle = [
          "proportional"
          "monospaced"
        ];
        fontType = [
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
