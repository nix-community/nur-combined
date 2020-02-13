{ stdenv, pkg-config, ncurses, w3m, ueberzug, sources }:

stdenv.mkDerivation rec {
  pname = "cfiles";
  version = stdenv.lib.substring 0 7 src.rev;
  src = sources.cfiles;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ncurses w3m ueberzug ];

  prePatch = ''
    substituteInPlace Makefile \
      --replace "prefix = usr" "prefix=$out"
    substituteInPlace scripts/clearimg \
      --replace "/usr/lib/w3m/w3mimgdisplay" "${w3m}/bin/w3mimgdisplay"
    substituteInPlace scripts/displayimg \
      --replace "/usr/lib/w3m/w3mimgdisplay" "${w3m}/bin/w3mimgdisplay"
    substituteInPlace scripts/displayimg_uberzug \
      --replace "ueberzug" "${ueberzug}/bin/ueberzug"
  '';

  meta = with stdenv.lib; {
    inherit (src) description homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
