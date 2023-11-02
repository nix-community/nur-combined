{ lib, stdenv, fetchFromGitHub, cmake, headerOnly ? false, enableAvx2 ? true }:

stdenv.mkDerivation rec {
  pname = "seq";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "Thermadiag";
    repo = "seq";
    rev = "dadbf3f6002acd89719c3110cf7441a71e0fc5b4";
    sha256 = "sha256-MKm1koQ9FRvfjB32UpWP3eZtVI5Idwm77JaBNUW32H0=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DHEADER_ONLY=${if headerOnly then "ON" else "OFF"}"
    "-DENABLE_AVX2=${if enableAvx2 then "ON" else "OFF"}"
    "-DCMAKE_CXX_FLAGS=-march=x86-64-v3"
  ];

  meta = with lib; {
    description = "Collection of original C++11 STL-like containers and related tools";
    homepage = "https://github.com/Thermadiag/seq";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
