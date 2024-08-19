{ stdenvNoCC, fetchurl }:

stdenvNoCC.mkDerivation rec {
  pname = "these-fonts";
  version = "1.0";

  src = fetchurl {
    url = "https://assets.zzzsy.top/${pname}.tar.xz";
    hash = "sha256-/89y0HfBVdMtpicmnZAnmmssdo0vSip3yMr3cXlF5xU=";
  };

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    mv *.ttf *.ttc *.TTF $_
  '';
}
