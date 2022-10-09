{ stdenvNoCC, lib, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "lora-cyrillic";
  version = "3.003";

  src = fetchFromGitHub {
    owner = "cyrealtype";
    repo = "Lora-Cyrillic";
    rev = "v3.003";
    sha256 = "1vdw2c4q18fvjnls541xg4031sswphd71wr3ybydv77m9dwp2szn";
  };

  installPhase = ''
    install -m444 -Dt $out/share/fonts/opentype/${pname} fonts/otf/*.otf
    install -m444 -Dt $out/share/fonts/truetype/${pname} fonts/ttf/*.ttf fonts/variable/*.ttf
    install -m444 -Dt $out/share/fonts/woff2/${pname} fonts/webfonts/*.woff2 fonts/variable/*.woff2
  '';

  meta = with lib; {
    homepage = "https://github.com/cyrealtype/Lora-Cyrillic";
    description = "Contemporary serif font that supports Latin and Cyrillic scripts. Includes OTF, TTF and variable.";
    license = licenses.ofl;
    platforms = platforms.all;
    # maintainers = with maintainers; [  ];
  };
}
