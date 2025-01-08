{ lib, stdenv, fetchFromGitHub, cmake, cpm-cmake, copacabana }:

stdenv.mkDerivation rec {
  pname = "kumi";
  version = "3.1";

  src = fetchFromGitHub {
    owner = "jfalcou";
    repo = "kumi";
    rev = "v${version}";
    hash = "sha256-9/l5GcnLRgSUq4RG7w7dzWmvpk2Z2FKJChiu6668qXo=";
  };

  nativeBuildInputs = [ cmake cpm-cmake ];

  preConfigure = ''
    mkdir cmake/cpm
    cp ${cpm-cmake}/share/cpm/CPM.cmake cmake/cpm/CPM_0.40.2.cmake
  '';

  cmakeFlags = [
    "-DCPM_SOURCE_CACHE=./cmake"
    "-DKUMI_BUILD_TEST=0"
    "-DCPM_COPACABANA_SOURCE=${copacabana}"
  ];

  meta = with lib; {
    description = "C++20 implementation of a tuple-like class";
    homepage = "https://github.com/jfalcou/kumi";
    license = licenses.boost;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
