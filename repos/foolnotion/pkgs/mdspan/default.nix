{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "mdspan";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "kokkos";
    repo = "mdspan";
    rev = "760060059fb746018a9849234e02dc9bf003861b";
    sha256 = "sha256-arGVZLFVT7NvYQlyGP+tAacY9w3C5dHlMzjDSjVQuVw=";
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
