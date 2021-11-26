{ lib, stdenv, fetchFromGitHub, cmake, doctest, fast_float, robin-hood-hashing }:

stdenv.mkDerivation rec {
  pname = "pratt-parser";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "foolnotion";
    repo = "pratt-parser-calculator";
    rev = "8b0b33289c7b9cb6a2d8e0db47ff69f3f9c0430b";
    sha256 = "sha256-nbEYG86Pz7fj3do6Q4XMOH6nG7uYi1yDI4HKZPVWUFY=";
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
