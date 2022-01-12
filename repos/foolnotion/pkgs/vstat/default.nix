{ lib, stdenv, fetchFromGitHub, cmake, vectorclass }:

stdenv.mkDerivation rec {
  pname = "vstat";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "heal-research";
    repo = "vstat";
    rev = "0862936ea9dea079c2f620e67979e97866af25a0";
    sha256 = "sha256-4JEZRuW9zum4+TE2NQqIZ14PKcwG5Akc7UXuZDGoOAc=";
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
