{ lib, stdenv, fetchFromGitHub, cmake, headerOnly ? false, enableAvx2 ? true }:

stdenv.mkDerivation rec {
  pname = "seq";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "Thermadiag";
    repo = "seq";
    rev = "v${version}";
    sha256 = "sha256-42srgHQY7A74iw1Rsn88cxAxa5QlZWPGis+xJswp6RI=";
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
