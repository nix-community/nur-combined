{ lib, stdenv, fetchgit, ncurses }:

stdenv.mkDerivation rec {
  pname = "sfeed_curses";
  version = "0.9.13";

  src = fetchgit {
    url = "git://git.codemadness.org/sfeed_curses";
    rev = version;
    sha256 = "sha256-Ckv9yGGYLO+zCsu30gqJwSJyG+HLuEV/91c6/xVI1c4=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace "-lcurses" "-lncurses"
  '';

  buildInputs = [ ncurses ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "sfeed curses UI";
    homepage = "https://git.codemadness.org/sfeed_curses/";
    license = licenses.isc;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
