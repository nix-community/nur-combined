{ lib, stdenv, fetchFromGitHub, bison, flex, libtool, ncurses, readline, zlib }:

stdenv.mkDerivation rec {
  pname = "foma";
  version = "2020-09-28";

  src = fetchFromGitHub {
    owner = "mhulden";
    repo = pname;
    rev = "b44022c7d9d347dc7392aabbf72c82e558767675";
    hash = "sha256-1Zvd0aAAElHemnVQ0YLZG7cZXYV2lebNq20kQ53Njy0=";
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
