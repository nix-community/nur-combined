{ lib
, stdenv
, fetchzip
, cmake
, libtgd
, qtbase
, qtwayland
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "qv";
  version = "5.1";

  src = fetchzip {
    url = "https://marlam.de/qv/releases/qv-${version}.tar.gz";
    hash = "sha256-zrpbpifk0cPbdaXfX7I75BFOuTLaoj59lx0aXKOoU8g=";
  };

  nativeBuildInputs = [
    cmake
    wrapQtAppsHook
  ];

  buildInputs = [
    libtgd
    qtbase
    qtwayland
  ];

  meta = with lib; {
    description = "A a viewer for 2D data such as images, sensor data, simulations, renderings and videos";
    homepage = "https://marlam.de/qv/";
    downloadPage = "https://marlam.de/qv/download/";
    license = licenses.mit;
  };
}
