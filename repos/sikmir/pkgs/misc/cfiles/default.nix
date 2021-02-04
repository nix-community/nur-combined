{ lib, stdenv, pkg-config, ncurses, w3m, ueberzug, sources }:

stdenv.mkDerivation {
  pname = "cfiles-unstable";
  version = lib.substring 0 10 sources.cfiles.date;

  src = sources.cfiles;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ncurses w3m ueberzug ];

  prePatch = ''
    substituteInPlace Makefile \
      --replace "CC = gcc" "" \
      --replace "prefix = usr" "prefix=$out"
    substituteInPlace scripts/clearimg \
      --replace "/usr/lib/w3m/w3mimgdisplay" "${w3m}/bin/w3mimgdisplay"
    substituteInPlace scripts/displayimg \
      --replace "/usr/lib/w3m/w3mimgdisplay" "${w3m}/bin/w3mimgdisplay"
    substituteInPlace scripts/displayimg_uberzug \
      --replace "ueberzug" "${ueberzug}/bin/ueberzug"
  '';

  meta = with lib; {
    inherit (sources.cfiles) description homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
