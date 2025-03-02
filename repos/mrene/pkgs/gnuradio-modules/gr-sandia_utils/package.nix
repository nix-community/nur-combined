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
}:

stdenv.mkDerivation rec {
  pname = "gr-sandia-utils";
  version = "unstable-2022-12-05";


  src = fetchFromGitHub {
    owner = "sandialabs";
    repo = "gr-sandia_utils";
    rev = "d71dd7a2af54309a2c88982dfaa0747dad1cc8ca";
    hash = "sha256-2iJv0h2kC9T+nCb+Ht254bFxlVG8zxhElm/3hYf2EF4=";
  };
  
  patches = lib.optionals stdenv.isDarwin [
    ./compile-fixes.diff
  ] ++ lib.optionals (!stdenv.isDarwin) [
    ./add-missing-cstdint.diff
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
    gnuradio.python.pkgs.pybind11
    gnuradio.python.pkgs.numpy
    gr-pdu_utils
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_CXX_STANDARD" "11")
  ];

  meta = with lib; {
    description = "Misc blocks";
    homepage = "https://github.com/sandialabs/gr-sandia_utils";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "gr-sandia-utils";
    platforms = platforms.unix;
  };
}
