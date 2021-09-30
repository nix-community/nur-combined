{ lib, mkDerivation, fetchFromGitHub, qmake, pkg-config
, fftw, sigutils
}:

mkDerivation rec {
  pname = "suwidgets";
  version = "2021-07-17";

  src = fetchFromGitHub {
    owner = "BatchDrake";
    repo = "SuWidgets";
    rev = "c45b2af3b24115335bf993671198f419fa3ed0f7";
    hash = "sha256-p+kgmtDWuBLlh8IJP5FeximeJSfz9M6Il3SRYz0TJgI=";
  };

  nativeBuildInputs = [ qmake pkg-config ];

  buildInputs = [ fftw sigutils ];

  qmakeFlags = [ "SuWidgetsLib.pro" "PREFIX=/" ];

  installFlags = [ "INSTALL_ROOT=$(out)" ];

  meta = with lib; {
    description = "Sigutils-related widgets";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
