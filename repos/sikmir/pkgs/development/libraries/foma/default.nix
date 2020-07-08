{ stdenv, bison, flex, libtool, ncurses, readline, zlib, sources }:

stdenv.mkDerivation {
  pname = "foma";
  version = stdenv.lib.substring 0 7 sources.foma.rev;
  src = sources.foma;

  sourceRoot = "source/foma";

  nativeBuildInputs = [ bison flex libtool ];

  buildInputs = [ ncurses readline zlib ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace "CC = gcc" "#CC = gcc" \
      --replace "-ltermcap" "-lncurses"
  '';

  makeFlags = [ "prefix=$(out)" ];

  meta = with stdenv.lib; {
    inherit (sources.foma) description homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ sikmir ];
    platforms = platforms.unix;
  };
}
