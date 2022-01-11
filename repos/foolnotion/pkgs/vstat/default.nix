{ lib, stdenv, fetchFromGitHub, cmake, vectorclass }:

stdenv.mkDerivation rec {
  pname = "vstat";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "heal-research";
    repo = "vstat";
    rev = "e6d16e7ba279f5e8730328e69a80ffae442702e3";
    sha256 = "sha256-ID771prG6A6MNO0TAhlei7OqC58OPw/h5wwHwQK0yTg=";
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
