{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "tl-expected";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "TartanLlama";
    repo = "expected";
    rev = "v${version}";
    hash = "sha256-+9M1++ZYaZNJGjEoI6+J8565R2wlznoDWW8MPrmCMoU=";
  };

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [
    "-DEXPECTED_BUILD_TESTS=OFF"
  ];

  meta = with lib; {
    description = "Single header implementation of std::expected with functional-style extension    s";
    homepage = "https://github.com/TartanLlama/expected";
    license = licenses.cc0;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
