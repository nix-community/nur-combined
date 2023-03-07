{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "fast_float";
  version = "3.10.1";

  src = fetchFromGitHub {
    owner = "fastfloat";
    repo = "fast_float";
    rev = "v${version}";
    sha256 = "sha256-YFQRIGOSN5fWgTLAI9srM0vnYzIo8NOy8Fi1Pob8F+A=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Fast header-only implementations for the C++ from_chars functions for float and double types.";
    homepage = "https://github.com/fastfloat/fast_float";
    license = licenses.asl20;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
