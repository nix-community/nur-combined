{ lib, stdenv, fetchFromGitHub, cmake, gmp }:

stdenv.mkDerivation rec {
  pname = "mppp";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "bluescarni";
    repo = "mppp";
    rev = "v${version}";
    hash = "sha256-rMBxeImeykF3r/I6lnA2va8XPHkNtL8OsORG0re2yOg=";
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
