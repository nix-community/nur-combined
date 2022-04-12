{ lib, stdenv, fetchFromGitHub, bison, flex, libtool, ncurses, readline, zlib }:

stdenv.mkDerivation rec {
  pname = "foma";
  version = "2022-02-26";

  src = fetchFromGitHub {
    owner = "mhulden";
    repo = pname;
    rev = "82f9acdef234eae8b7619ccc3a386cc0d7df62bc";
    hash = "sha256-2ZL7SdjFmf1zD+jRsg0XybyX7mRsqbWV1ZMhiQINwO0=";
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
