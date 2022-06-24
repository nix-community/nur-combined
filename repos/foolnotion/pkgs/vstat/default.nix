{ lib, stdenv, fetchFromGitHub, cmake, vectorclass }:

stdenv.mkDerivation rec {
  pname = "vstat";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "heal-research";
    repo = "vstat";
    rev = "a1ee87f3fa4c22e9c9a5e24d80a2cf2769134e35";
    sha256 = "sha256-B4vNDxV2a5/Hwjj7Dc6MCXG8YFW5/Z5LWsCGCB79PJc=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ vectorclass ];

  meta = with lib; {
    description = "C++17 library of computationally efficient methods for calculating sample statistics (mean, variance, covariance, correlation).";
    homepage = "https://github.com/heal-research/vstat";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
