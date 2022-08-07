{ lib, stdenv, fetchFromGitHub, cmake, qtcharts, qtbase, wrapQtAppsHook }:

stdenv.mkDerivation rec {
  pname = "seer";
  version = "1.7";

  src = fetchFromGitHub {
    owner = "epasveer";
    repo = "seer";
    rev = "v${version}";
    sha256 = "sha256-/EuXit1kHW2cdqa5BJEj29Wu3WafVZb6DpPnIg2tDP0=";
  };

  buildInputs = [ qtbase qtcharts ];
  nativeBuildInputs = [ cmake wrapQtAppsHook ];

  preConfigure = ''
    cd src
  '';

  meta = with lib; {
    description = "A Qt gui frontend for GDB.";
    homepage = "https://github.com/epasveer/seer";
    license = licenses.gpl3;
    platforms = platforms.linux;
    #maintainers = with maintainers; [ foolnotion ];
  };
}

