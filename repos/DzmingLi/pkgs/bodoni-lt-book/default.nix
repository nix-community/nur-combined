{ pkgs, stdenvNoCC, fetchurl, ... }:

stdenvNoCC.mkDerivation {
  pname = "bodoni-lt-book";
  version = "6.1";
  src = fetchurl {
    url = "https://github.com/DzmingLi/nur-packages/releases/download/bodoni-lt-book-6.1/BodoniLT-Book-6.1.ttf";
    hash = "sha256-I4oiSgFsbUzUfVdbivUlnXbS1JHgOADonLkW4MvQ7U4=";
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm644 $src $out/share/fonts/truetype/BodoniLT-Book.ttf
  '';

  meta = with pkgs.lib; {
    description = "Bodoni LT Book — a serif typeface by Linotype";
    homepage = "https://www.linotype.com/";
    license = licenses.unfree;
    platforms = platforms.all;
  };
}
