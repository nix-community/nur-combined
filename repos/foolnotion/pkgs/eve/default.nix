{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "eve";
  version = "2022.09.1";

  src = fetchFromGitHub {
    owner = "jfalcou";
    repo = "eve";
    rev = "a3dd116346d8b2d2e940f279e5b2aa3e32c0f88b";
    sha256 = "sha256-AjbWdUIswkdIhd10alafcc6Kpw8Q++bxxpkq3ulrj0w=";
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
