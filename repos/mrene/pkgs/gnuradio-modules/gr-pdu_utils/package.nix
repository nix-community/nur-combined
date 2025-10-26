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
  pname = "gr-pdu-utils";
  version = "1.2";

  # src = ./gr-pdu_utils;
  src = fetchFromGitHub {
    owner = "sandialabs";
    repo = "gr-pdu_utils";
    rev = "68984503712114bbabb4d6b8814d3997144f025b";
    hash = "sha256-FOvvE9lzxTxre7y2undXh0zuPfeJGv3+5R3t/UGAVfw=";
  };

  patches = [
    ./fix-bitset-include.diff
  ];

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
    mpir
    gnuradio.python.pkgs.pybind11
    gnuradio.python.pkgs.numpy
  ];

  meta = with lib; {
    description = "GNU Radio PDU Utilities";
    homepage = "https://github.com/sandialabs/gr-pdu_utils.git";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "gr-pdu-utils";
    platforms = platforms.unix;
  };
}
