{ stdenv, pkg-config, ncurses, w3m, ueberzug, cfiles }:

stdenv.mkDerivation rec {
  pname = "cfiles";
  version = stdenv.lib.substring 0 7 src.rev;
  src = cfiles;

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
    description = cfiles.description;
    homepage = cfiles.homepage;
    license = licenses.mit;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
