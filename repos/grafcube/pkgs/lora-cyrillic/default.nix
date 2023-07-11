{ stdenvNoCC, lib, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "lora-cyrillic";
  version = "3.005";

  src = fetchFromGitHub {
    owner = "cyrealtype";
    repo = pname;
    rev = "v${version}";
    sha256 = "0nxpcvdgh76l1yq70886gi6av8cc3xcf766h0mcgfin58c6vqxhh";
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
