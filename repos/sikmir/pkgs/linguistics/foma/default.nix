{ lib, stdenv, fetchFromGitHub, bison, flex, libtool, ncurses, readline, zlib }:

stdenv.mkDerivation rec {
  pname = "foma";
  version = "2021-06-04";

  src = fetchFromGitHub {
    owner = "mhulden";
    repo = pname;
    rev = "180b6febf718af4b0223b6c7ac46f698a76e6a45";
    hash = "sha256-6pdd9yQ+o2uPwPWSFPUSpTk/UC/up8xv1SZY++hKPPk=";
  };

  sourceRoot = "${src.name}/foma";

  nativeBuildInputs = [ bison flex libtool ];

  buildInputs = [ ncurses readline zlib ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace "CC = gcc" "#CC = gcc" \
      --replace "-ltermcap" "-lncurses"
  '';

  makeFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    description = "xfst-compatible C++ finite-state transducer library";
    longDescription = ''
      Foma is designed to be a complete replacement for the
      closed-source Xerox tool xfst. Everything that compiles
      with xfst should compile with Foma. If not it is a bug.
    '';
    homepage = "https://code.google.com/p/foma/";
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
