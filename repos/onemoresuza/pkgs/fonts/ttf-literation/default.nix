{
  stdenvNoCC,
  fetchzip,
  lib,
}:
stdenvNoCC.mkDerivation rec {
  pname = "ttf-literation";
  version = "3.0.2";
  src = fetchzip {
    url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/LiberationMono.tar.xz";
    #
    # It's a flat list of files
    #
    stripRoot = false;
    sha256 = "sha256-DKQ5kI/J1BFKWhVZ/uJdOqbkJC2ffjSapaGUdpt7eCw=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p "$out/share/fonts/truetype/ttf-literation"
    mv *.ttf "$out/share/fonts/truetype/ttf-literation"
  '';

  meta = with lib; {
    description = "A ttf Nerd Font based on ttf-liberation";
    homepage = "https://www.nerdfonts.com/";
    license = licenses.ofl;
  };
}
