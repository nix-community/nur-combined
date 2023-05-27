{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "fast_float";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "fastfloat";
    repo = "fast_float";
    rev = "v${version}";
    sha256 = "sha256-pJ3ZkfFQL8JjjuI/GNYvjzAqu+yBAvu26fAiAQxqE/g=";
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
