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
  version = "unstable-2023-03-02";

  src = fetchFromGitHub {
    owner = "KDAB";
    repo = pname;
    rev = "e3879212bc3265563f922d1bc57ef343bdcb9768";
    hash = "sha256-Sqy9QeFhqAX8wKpfHbQTTXbWf0cXU/MRxLRFEqp2eRU=";
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

