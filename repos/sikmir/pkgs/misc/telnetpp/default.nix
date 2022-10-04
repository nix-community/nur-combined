{ lib, stdenv, fetchFromGitHub, cmake, doxygen, boost, gsl-lite, gtest, zlib }:

stdenv.mkDerivation rec {
  pname = "telnetpp";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "KazDragon";
    repo = "telnetpp";
    rev = "v${version}";
    hash = "sha256-BfRu0dv2d7qwz2jTdaQczOQQBO3qmO1E754hWqxT66g=";
  };

  nativeBuildInputs = [ cmake doxygen ];

  buildInputs = [ boost gsl-lite gtest zlib ];

  cmakeFlags = [ "-DTELNETPP_WITH_ZLIB=True" ];

  meta = with lib; {
    description = "A C++ library for interacting with Telnet streams";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
