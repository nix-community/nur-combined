{ lib, stdenv, fetchFromGitHub, cmake, qmake, qtsvg, qt5compat, qtbase }:

stdenv.mkDerivation rec {
  pname = "cutechess";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "cutechess";
    repo = "cutechess";
    rev = "v${version}";
    sha256 = "sha256-nWY6A1fD4L24Dchp9x3v0s6rsDebSxZYBmXDZbP912c=";
  };

  buildInputs = [ qtbase qtsvg qt5compat ];

  nativeBuildInputs = [ cmake qmake ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "Graphical user interface, command-line interface and library for playing chess";
    homepage = "https://github.com/cutechess/cutechess";
    license = licenses.gpl3;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}

