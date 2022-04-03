{ lib, stdenv, fetchFromGitHub, qmake, qtsvg, qtbase }:

stdenv.mkDerivation rec {
  pname = "cutechess";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "cutechess";
    repo = "cutechess";
    rev = "e47db4d9553d9a76202ee3c8f2357f5d3ed59f49";
    sha256 = "sha256-hRVQfiE0bbsrz7sxGmI7Q5ztAbg2G5vYbjtKkuH6w+U=";
  };

  buildInputs = [ qtbase qtsvg ];

  nativeBuildInputs = [ qmake ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "Graphical user interface, command-line interface and library for playing chess.";
    homepage = "https://github.com/cutechess/cutechess";
    license = licenses.gpl3;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };

  installPhase = ''
    mkdir -p $out/bin
    strip projects/cli/cutechess-cli
    strip projects/gui/cutechess

    cp projects/cli/cutechess-cli $out/bin/
    cp projects/gui/cutechess $out/bin/
    '';
}

