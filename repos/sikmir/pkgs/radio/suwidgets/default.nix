{ lib, stdenv, fetchFromGitHub, qmake, pkg-config
, fftw, sigutils
}:

stdenv.mkDerivation rec {
  pname = "suwidgets";
  version = "2022-04-03";

  src = fetchFromGitHub {
    owner = "BatchDrake";
    repo = "SuWidgets";
    rev = "826b3eeae5b682dc063f53b427caa9c7c48131ea";
    hash = "sha256-cyFLsP+8GbALdlgEnVX4201Qq/KAxb/Vv+sJqbFpvUk=";
  };

  nativeBuildInputs = [ qmake pkg-config ];

  buildInputs = [ fftw sigutils ];

  qmakeFlags = [ "SuWidgetsLib.pro" "PREFIX=/" ];

  installFlags = [ "INSTALL_ROOT=$(out)" ];

  dontWrapQtApps = true;

  meta = with lib; {
    description = "Sigutils-related widgets";
    inherit (src.meta) homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
