{ stdenv, dash, help2man, ncurses, scdoc, libshell }:

stdenv.mkDerivation rec {
  pname = "libshell";
  version = stdenv.lib.substring 0 7 src.rev;
  src = libshell;

  nativeBuildInputs = [ help2man scdoc ];
  buildInputs = [ dash ncurses ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace "/usr" ""
    substituteInPlace utils/Makefile \
      --replace "/usr" ""
    substituteInPlace utils/cgrep.in \
      --replace "/bin/ash" "${dash}/bin/dash"
  '';

  makeFlags = [ "DESTDIR=$(out)" ];

  doCheck = false;

  meta = with stdenv.lib; {
    description = libshell.description;
    homepage = libshell.homepage;
    license = licenses.gpl2;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.all;
  };
}
