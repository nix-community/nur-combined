{
  maintainers,
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  ninja,
  qt6,
  libusb1,
  ffmpeg,
  ...
}:
let
  pname = "domesdayduplicator";
  version = "2.4";

  rev = "V${version}";
  hash = "sha256-BC/nUqcr4Vkqww3Uw6j0X8NxK2vkf4qVHVfgDg2Ubb0=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    inherit hash rev;
    owner = "harrypm";
    repo = "DomesdayDuplicator";
  };

  dontWrapQtApps = true;

  sourceRoot = "source/Linux-Application";

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtserialport
    qt6.qtmultimedia
    libusb1
    ffmpeg
  ];

  cmakeFlags = [
    (lib.cmakeFeature "USE_QT_VERSION" "6")
  ];

  meta = {
    inherit maintainers;
    description = "The Domesday Duplicator is a USB3 based DAQ capable of 40 million samples per second (20mhz of bandwith) aquisition of analogue RF data.";
    homepage = "https://github.com/harrypm/DomesdayDuplicator";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
