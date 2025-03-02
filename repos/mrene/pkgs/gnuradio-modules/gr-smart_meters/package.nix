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
, gr-timing_utils
, gr-fhss_utils
, gr-smart_meters
, gr-fosphor
}:

let 
  gnuradio = gnuradio-boost181;
in
stdenv.mkDerivation rec {
  pname = "gr-smart-meters";
  version = "unstable-2023-09-25";

  src = fetchFromGitHub {
    owner = "BitBangingBytes";
    repo = "gr-smart_meters";
    rev = "eae55c97ba0a14ba389e21a3e2ed32e6a1e66cdd";
    hash = "sha256-Q5ODvprUNYo00QjPS0Hnon+IiOBfTG0f168BgDrxu2c=";
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
    boost181
    volk
    gnuradio.python.pkgs.pybind11
    gnuradio.python.pkgs.numpy
    gr-sandia_utils
    gr-pdu_utils
    gr-timing_utils
    gr-fhss_utils
  ];

  passthru = 
    let 
    gnuradioPackages = {
      inherit gr-pdu_utils gr-sandia_utils gr-timing_utils gr-fhss_utils gr-smart_meters gr-fosphor;
    };
    gr = (gnuradio.override {
      extraPackages = builtins.attrValues gnuradioPackages;
      extraPythonPackages = with gnuradio.python.pkgs; [ soapysdr simplekml (callPackage ../../python-packages/gmplot/package.nix {}) ];
    }) // {
      pkgs = gnuradio.pkgs.overrideScope (final: prev: gnuradioPackages);
    };
  in
  {
    gnuradio = gr;
  };
  meta = with lib; {
    description = "";
    homepage = "https://github.com/BitBangingBytes/gr-smart_meters.git";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ ];
    mainProgram = "gr-smart-meters";
    platforms = platforms.unix;
  };
}
