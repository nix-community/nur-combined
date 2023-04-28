{ boost
, cmake
, curl
, fdk-aac-encoder
, fetchFromGitHub
, fftwSinglePrec
, git
, gmp
, gnuradio3_9
, hackrf
, lib
, libsndfile
, log4cpp
, mpir
, openssl
, pkg-config
, sox
, stdenv
, uhd
, volk
}:

stdenv.mkDerivation rec {
  pname = "trunk-recorder";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "robotastic";
    repo = "${pname}";
    rev = "v${version}";
    sha256 = "sha256-yGc585254s7UwqXyQzYrW7dELvEPAn7UqoBsmfbKZM4=";
  };

  nativeBuildInputs = [ cmake git pkg-config ];
  cmakeFlags = [
    "-DCMAKE_SKIP_BUILD_RPATH=ON"
  ];

  buildInputs = [
    boost
    curl
    fdk-aac-encoder
    fftwSinglePrec
    gmp
    gnuradio3_9
    gnuradio3_9.pkgs.osmosdr
    hackrf
    libsndfile
    log4cpp
    mpir
    openssl
    pkg-config
    sox
    uhd
    volk
  ];

  meta = with lib; {
    description = "Records calls from a Trunked Radio System (P25 & SmartNet)";
    homepage = "https://github.com/robotastic/trunk-recorder";
    license = licenses.gpl3;
  };
}
