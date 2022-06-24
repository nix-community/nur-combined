{ lib, stdenv, fetchFromGitHub, cmake, doctest, fast_float, robin-hood-hashing }:

stdenv.mkDerivation rec {
  pname = "pratt-parser";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "foolnotion";
    repo = "pratt-parser-calculator";
    rev = "a15528b1a9acfe6adefeb41334bce43bdb8d578c";
    sha256 = "sha256-lv55MHRqlklySTinFn/8CfZRq7XGUfZQxAAPYJJUcC0=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    fast_float
  ];

  meta = with lib; {
    description = "Very simple operator precedence parser following the well-known Pratt algorithm.";
    homepage = "https://github.com/foolnotion/pratt-parser-calculator";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
