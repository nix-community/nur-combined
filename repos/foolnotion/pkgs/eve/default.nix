{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "eve";
  version = "2023.02.15";

  src = fetchFromGitHub {
    owner = "jfalcou";
    repo = "eve";
    rev = "v${version}";
    sha256 = "sha256-k7dDtLR9PoJp9SR0z4j6uNwm8JOJQiHXbr09kXtRJ7g=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DEVE_BUILD_TEST=OFF" "-DEVE_BUILD_BENCHMARKS=OFF" "-DEVE_BUILD_DOCUMENTATION=OFF" ];

  meta = with lib; {
    description = "EVE - the Expressive Vector Engine in C++20.";
    homepage = "https://github.com/jfalcou/eve";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
