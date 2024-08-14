{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, gnuradio
, spdlog
, gmp
, mpir
, boost
, volk
, libGL
, opencl-headers
, ocl-icd
, freetype
, libX11
, qt5
, libsForQt5
}:

stdenv.mkDerivation rec {
  pname = "gr-fosphor";
  version = "unstable-2024-03-23";

  src = fetchFromGitHub {
    owner = "osmocom";
    repo = "gr-fosphor";
    rev = "74d54fc0b3ec9aeb7033686526c5e766f36eaf24";
    hash = "sha256-FBmH4DmKATl0FPFU7T30OrYYmxlSTTLm1SZpt0o1qkw=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    gnuradio
    spdlog
    gmp
    mpir
    boost
    volk
    gnuradio.python.pkgs.pybind11
    gnuradio.python.pkgs.numpy
    libGL
    opencl-headers
    ocl-icd
    freetype
    libX11
    qt5.qtbase
  ];

  dontWrapQtApps = true;


  meta = with lib; {
    description = "GNURadio block for spectrum visualization using GPU; mirror of https://gitea.osmocom.org/sdr/gr-fosphor";
    homepage = "https://github.com/osmocom/gr-fosphor";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "gr-fosphor";
    platforms = platforms.all;
  };
}
