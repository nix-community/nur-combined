{ lib, stdenv, bison, flex, libtool, ncurses, readline, zlib, sources }:

stdenv.mkDerivation {
  pname = "foma-unstable";
  version = lib.substring 0 10 sources.foma.date;

  src = sources.foma;

  sourceRoot = "foma-src/foma";

  nativeBuildInputs = [ bison flex libtool ];

  buildInputs = [ ncurses readline zlib ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace "CC = gcc" "#CC = gcc" \
      --replace "-ltermcap" "-lncurses"
  '';

  makeFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    inherit (sources.foma) description homepage;
    license = licenses.asl20;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
