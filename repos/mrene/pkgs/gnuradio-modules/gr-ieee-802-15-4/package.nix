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
}:

stdenv.mkDerivation rec {
  pname = "gr-ieee802-15-4";
  version = "3.6";

  src = fetchFromGitHub {
    owner = "bastibl";
    repo = "gr-ieee802-15-4";
    rev = "a210b11fed2d307ef797ea79842b54f4e8ed3dd5";
    hash = "sha256-m/CukP6Wf+POr3LJXh4uIWfWb3l9tnMI6tufq2a//J8=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = let 
    gnuradio = gnuradio-boost181; 
  in [
    gnuradio.unwrapped
    spdlog
    gmp
    mpir
    boost181
    volk
    gnuradio.python.pkgs.pybind11
    gnuradio.python.pkgs.numpy
  ];

  meta = with lib; {
    description = "IEEE 802.15.4 ZigBee Transceiver";
    homepage = "https://github.com/bastibl/gr-ieee802-15-4";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "gr-ieee802-15-4";
    platforms = platforms.unix;
  };
}
