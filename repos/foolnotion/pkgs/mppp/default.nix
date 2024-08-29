{ lib, stdenv, fetchFromGitHub, cmake, gmp }:

stdenv.mkDerivation rec {
  pname = "mppp";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "bluescarni";
    repo = "mppp";
    rev = "v${version}";
    hash = "sha256-XNw7ndQs+KMsmPWLihYdfeRU/sI/ometxOVrJVVeGQA=";
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
