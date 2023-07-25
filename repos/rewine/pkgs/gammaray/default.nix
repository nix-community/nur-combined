{ lib
, stdenv
, fetchFromGitHub
, libsForQt5
, cmake
, pkg-config
, wayland
, elfutils
, libelfin
, libbfd
, libdwarf
}:
let
  qmake = libsForQt5.qmake;
  wrapQtAppsHook = libsForQt5.qt5.wrapQtAppsHook;
in
stdenv.mkDerivation rec {
  pname = "GammaRay";
  version = "unstable-2023-06-22";

  src = fetchFromGitHub {
    owner = "KDAB";
    repo = pname;
    rev = "8f2dfd4eb2aa58885f59405c5a247de100c2a41c";
    hash = "sha256-qhhtbNjX/sPMqiTPRW+joUtXL9FF0KjX00XtS+ujDmQ=";
  };

  nativeBuildInputs = [ cmake wrapQtAppsHook pkg-config ];

  buildInputs = [
    wayland
    elfutils
    libelfin #
    libbfd
    libdwarf #
  ];

  meta = with lib; {
    description = "A software introspection tool for Qt applications developed by KDAB";
    homepage = "https://github.com/KDAB/GammaRay";
    license = licenses.gpl2Plus;
  };
}

