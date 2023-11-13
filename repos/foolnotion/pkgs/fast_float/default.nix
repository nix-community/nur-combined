{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "fast_float";
  version = "5.3.0";

  src = fetchFromGitHub {
    owner = "fastfloat";
    repo = "fast_float";
    rev = "v${version}";
    hash = "sha256-zHSLoGhlKkF0PP7TQNUzgv2Qn3yeBR5hqQ8X5lxoUeg=";
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
