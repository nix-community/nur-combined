{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, opencv4, rtl-sdr, zlib }:

stdenv.mkDerivation rec {
  pname = "goestools";
  version = "2022-11-11";

  src = fetchFromGitHub {
    owner = "pietern";
    repo = "goestools";
    rev = "865e5c73683f8f688d102748e6b495ab5978768f";
    hash = "sha256-sbYQAh7auQ/lDYyk0b5q1SScU6q7O0Q7DNgZ0t9pHag=";
    fetchSubmodules = true;
  };

  postPatch = ''
    sed -i '8i #include <cstdint>' src/dcs/dcs.h
    sed -i '4i #include <cstdint>' src/assembler/vcdu.h
  '';

  nativeBuildInputs = [ cmake pkg-config ];

  buildInputs = [ opencv4 rtl-sdr zlib ];

  meta = with lib; {
    description = "Tools to work with signals and files from GOES satellites";
    homepage = "https://pietern.github.io/goestools/";
    license = licenses.bsd2;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
