{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, gnuradio-boost181
, spdlog
, gmp
, mpir
, boost181
, volk
, libGL
, opencl-headers
, ocl-icd
, freetype
, libX11
, qt5
, libsForQt5
, darwin
, glfw
}:

stdenv.mkDerivation rec {
  pname = "gr-fosphor";
  version = "unstable-2024-03-23";

  # src = ./gr-fosphor;
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

  buildInputs = let 
    gnuradio = gnuradio-boost181; 
  in [
    gnuradio
    spdlog
    gmp
    mpir
    boost181
    volk
    gnuradio.python.pkgs.pybind11
    gnuradio.python.pkgs.numpy
    libGL
    freetype
    libX11
    qt5.qtbase
    glfw
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.OpenCL
  ] ++ lib.optionals stdenv.isLinux [
    opencl-headers
    ocl-icd
  ];

  dontWrapQtApps = true;
  NIX_CFLAGS_COMPILE = "-Wno-deprecated-declarations"; 

  meta = with lib; {
    description = "GNURadio block for spectrum visualization using GPU; mirror of https://gitea.osmocom.org/sdr/gr-fosphor";
    homepage = "https://github.com/osmocom/gr-fosphor";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "gr-fosphor";
    platforms = platforms.unix; # TODO: Fix darwin build
  };
}
