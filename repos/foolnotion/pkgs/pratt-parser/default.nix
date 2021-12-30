{ lib, stdenv, fetchFromGitHub, cmake, doctest, fast_float, robin-hood-hashing }:

stdenv.mkDerivation rec {
  pname = "pratt-parser";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "foolnotion";
    repo = "pratt-parser-calculator";
    rev = "7a73a0cc8005fadeeff34040d247766dd77b18b1";
    sha256 = "sha256-oCt7UyKWq+lsoae8jiRjcb9xkU6jyhqsAaZME1m5YnI=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    fast_float
    robin-hood-hashing
  ];

  meta = with lib; {
    description = "Very simple operator precedence parser following the well-known Pratt algorithm.";
    homepage = "https://github.com/foolnotion/pratt-parser-calculator";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
