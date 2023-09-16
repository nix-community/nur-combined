{ lib, stdenv, fetchFromGitHub, qmake, libxcb, qtbase, qtsvg, qtmultimedia, wrapQtAppsHook }:

stdenv.mkDerivation rec {
  pname = "q5go";
  version = "2.1.3";

  src = fetchFromGitHub {
    owner = "bernds";
    repo = "q5go";
    rev = "${pname}-${version}";
    sha256 = "sha256-MQ/FqAsBnQVaP9VDbFfEbg5ymteb/NSX4nS8YG49HXU=";
  };

  nativeBuildInputs = [ qmake wrapQtAppsHook ];

  buildInputs = [ qtbase qtsvg qtmultimedia libxcb ];

  configurePhase = ''
    qmake ./src/q5go.pro PREFIX=$out
    '';

  meta = with lib; {
    description = "SGF editor and analysis frontend for KataGo, Leela Zero or compatible engines";
    homepage = "https://github.com/bernds/q5go";
    license = licenses.gpl2;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}

