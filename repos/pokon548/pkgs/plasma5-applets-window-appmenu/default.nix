{ lib
, mkDerivation
, stdenv
, fetchFromGitHub
, cmake
, extra-cmake-modules
, qtx11extras
, plasma-framework
, kdecoration
, qtbase
, qtdeclarative
, kirigami2
, xrandr
, libSM
, plasma-workspace
, unstableGitUpdater
}:

mkDerivation rec {
  pname = "plasma5-applets-window-appmenu";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "psifidotos";
    repo = "applet-window-appmenu";
    rev = "b7ac182e3e32b9b6da45e0be00c1d7919fcbdd7d";
    sha256 = "sha256-ckbrSmZowy1+rp17C8OBnpX8wHRSmDRcdYjOhj4JunQ=";
  };

  nativeBuildInputs = [ cmake extra-cmake-modules ];

  buildInputs = [
    qtx11extras
    plasma-framework
    kdecoration
    qtbase
    qtdeclarative
    kirigami2
    xrandr
    libSM
    plasma-workspace
  ];

  passthru = {
    updateScript = unstableGitUpdater { };
  };

  meta = with lib; {
    description = "Plasma 5 applet in order to show the window appmenu";
    homepage = "https://github.com/psifidotos/applet-window-appmenu";
    license = licenses.gpl2;
  };
}
