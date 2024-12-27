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
, gr-pdu_utils
, gr-sandia_utils
, gr-timing_utils
, llvmPackages
}:

stdenv.mkDerivation rec {
  pname = "gr-fhss-utils";
  version = "unstable-2023-08-17";

  src = fetchFromGitHub {
    owner = "sandialabs";
    repo = "gr-fhss_utils";
    rev = "8993c6a89444e740b06ff4829b94555b04433bf7";
    hash = "sha256-HLLXAfdTtALnHNJ7lBkLCksmk5tMD595jAEqjtgXRw4=";
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
    gr-sandia_utils
    gr-pdu_utils
    gr-timing_utils 
  ] ++ lib.optionals stdenv.isDarwin [ llvmPackages.openmp ];

  meta = with lib; {
    description = "Bursty modem utilities";
    homepage = "https://github.com/sandialabs/gr-fhss_utils.git";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "gr-fhss-utils";
    platforms = platforms.unix;
  };
}
