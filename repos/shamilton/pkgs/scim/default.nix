{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, gnuplot
, which
, bison
, ncurses
}:

stdenv.mkDerivation rec {
  pname = "scim";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "andmarti1424";
    repo = "sc-im";
    rev = "v${version}";
    sha256 = "sha256-QlnxMe0WsRX9J2xzpf2Udcf9+N3MvQWqmYl2YKsGpYM=";
  };

  sourceRoot = "source/src";
  nativeBuildInputs = [ which gnuplot bison pkg-config ];
  buildInputs = [ ncurses ];

  makeFlags = [ "prefix=${placeholder "out"}"];

  meta = with lib; {
    description = "Ncurses spreadsheet program for the terminal";
    license = licenses.lgpl3Plus;
    homepage = "https://github.com/andmarti1424/sc-im";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
