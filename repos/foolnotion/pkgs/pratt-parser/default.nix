{ lib, stdenv, fetchFromGitHub, cmake, doctest, fast_float, robin-hood-hashing }:

stdenv.mkDerivation rec {
  pname = "pratt-parser";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "foolnotion";
    repo = "pratt-parser-calculator";
    rev = "aec4b169e17a716af7f39623598d6de78c05505d";
    sha256 = "sha256-h653bhhRRqJ6BOsZEvGoCx3diOBT18/QMTnw/2iQ6+M=";
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
