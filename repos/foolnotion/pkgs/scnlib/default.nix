{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "scnlib";
  version = "0.4-pre";

  src = fetchFromGitHub {
    owner = "eliaskosunen";
    repo = "scnlib";
    rev = "815782badc1b548c21bb151372497e1516bee806";
    sha256 = "sha256-Y5ANxykHH/Ry4vOTjNMC77PEMzwqC2FNY8qKRVyPREM=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DSCN_TESTS=OFF" "-DSCN_BENCHMARKS=OFF" ];

  meta = with lib; {
    description = "Modern C++ library for replacing scanf and std::istream. .";
    homepage = "https://scnlib.readthedocs.io/";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
