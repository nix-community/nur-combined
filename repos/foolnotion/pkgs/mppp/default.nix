{ lib, stdenv, fetchFromGitHub, cmake, gmp }:

stdenv.mkDerivation rec {
  pname = "mppp";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "bluescarni";
    repo = "mppp";
    rev = "v${version}";
    hash = "sha256-nKNW+z+ShItJYyJ34MkRp+vwHcCNpH6MKF1lEXPQlWc=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ gmp ];

  meta = with lib; {
    description = "C++11/14/17/20 library for multiprecision arithmetic";
    homepage = "https://github.com/bluescarni/mppp";
    license = licenses.mpl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
