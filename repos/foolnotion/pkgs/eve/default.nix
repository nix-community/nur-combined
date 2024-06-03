{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "eve";
  version = "2023.02.15";

  src = fetchFromGitHub {
    owner = "jfalcou";
    repo = "eve";
    rev = "2cb833a3e0abfe25b78ec6cff51a9b50a9da49a7";
    sha256 = "sha256-4quYSvF4j0hKnCdNHW6qh0svfrOTIs4iAB0tIYB/hHc=";
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
