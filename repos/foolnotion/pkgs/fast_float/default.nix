{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "fast_float";
  version = "3.7.0";

  src = fetchFromGitHub {
    owner = "fastfloat";
    repo = "fast_float";
    rev = "v${version}";
    sha256 = "sha256-DPepihQI/l3M7cF5VvSKugff6c13VzXur+GwKIl2EdE=";
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
