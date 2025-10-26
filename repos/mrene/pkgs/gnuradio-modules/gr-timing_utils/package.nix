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
, gr-pdu_utils
, gr-sandia_utils
}:

stdenv.mkDerivation rec {
  pname = "gr-timing-utils";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "sandialabs";
    repo = "gr-timing_utils";
    rev = "454dfc40a1aa761337ddfaf58e98f46472d6cf62";
    hash = "sha256-evnngErcbzhHsYMCMFbCtjAJpId102gaGu1MhCXNd9Q=";
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
    gr-sandia_utils
    gr-pdu_utils
  ];

  meta = with lib; {
    description = "GNU Radio Timing Utilties";
    homepage = "https://github.com/sandialabs/gr-timing_utils.git";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "gr-timing-utils";
    platforms = platforms.unix;
  };
}
