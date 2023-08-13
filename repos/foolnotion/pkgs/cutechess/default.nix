{ lib, stdenv, fetchFromGitHub, cmake, qmake, qtsvg, qt5compat, qtbase }:

stdenv.mkDerivation rec {
  pname = "cutechess";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "cutechess";
    repo = "cutechess";
    rev = "v${version}";
    sha256 = "sha256-P44Twbw2MGz+oTzPwMFCe73zPxAex6uYjSTtaUypfHw=";
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

