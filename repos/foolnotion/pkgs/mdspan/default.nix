{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "mdspan";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "kokkos";
    repo = "mdspan";
    rev = "${pname}-${version}";
    sha256 = "sha256-sYXgUaQZfG7kBZtD2ABkTveiknB8Y07U3BZE+8QD8pQ=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DCMAKE_CXX_STANDARD=20"
    "-DMDSPAN_CXX_STANDARD=20"
    "-DMDSPAN_ENABLE_TESTS=OFF"
    "-DMDSPAN_ENABLE_BENCHMARKS=OFF"
  ];

  meta = with lib; {
    description = "Header-only implementation of ISO-C++ proposal P0009 (non-owning multi-dimensional array)";
    homepage = "https://github.com/kokkos/mdspan";
    license = licenses.bsd3;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
