{ lib, stdenv, fetchgit, ncurses }:

stdenv.mkDerivation rec {
  pname = "sfeed_curses";
  version = "1.0";

  src = fetchgit {
    url = "git://git.codemadness.org/${pname}";
    rev = version;
    sha256 = "sha256-Vnnsa/GDgcBEyelxIw9JN2Yuhxpp5UfSDPnezID6mU8=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace "-lcurses" "-lncurses"
  '';

  buildInputs = [ ncurses ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "sfeed curses UI";
    homepage = "https://git.codemadness.org/sfeed_curses/";
    license = licenses.isc;
    platforms = platforms.linux;
    maintainers = [ maintainers.sikmir ];
    skip.ci = stdenv.isDarwin;
  };
}
