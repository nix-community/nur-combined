{ lib
, fetchFromGitHub
, stdenv
, cmake
, pkg-config
, qt6
, libusb1
, ...
}:
let
  rev = "653524f86e7832a88f935655a2f36dcc9c70dea0";
in
stdenv.mkDerivation {
  name = "DomesdayDuplicator";

  src = fetchFromGitHub {
    inherit rev;
    owner = "harrypm";
    repo = "DomesdayDuplicator";
    sha256 = "sha256-V0rpbzG3Pfvgf47P/0ZcvBVIo5CG/X2fNjEqHW2Lu7s=";
  };

  dontWrapQtApps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtserialport
    qt6.qtmultimedia
    libusb1
  ];

  preConfigure = ''
    cd Linux-Application
  '';

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DUSE_QT_VERSION=6"
  ];

  meta = with lib; {
    description = "The Domesday Duplicator is a USB3 based DAQ capable of 40 million samples per second (20mhz of bandwith) aquisition of analogue RF data.";
    license = licenses.gpl3;
    maintainers = [ "JuniorIsAJitterbug" ];
    homepage = "https://github.com/harrypm/DomesdayDuplicator";
  };
}
