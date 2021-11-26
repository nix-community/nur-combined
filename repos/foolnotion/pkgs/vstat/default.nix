{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "vstat";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "heal-research";
    repo = "vstat";
    rev = "2796c5358c74bfcbeaf8d0411f7d6452b55cf912";
    sha256 = "sha256-PjTmZuXquABQ5h3ydjtVlX106p//Ol5wEipBNCWQjYg=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "C++17 library of computationally efficient methods for calculating sample statistics (mean, variance, covariance, correlation).";
    homepage = "https://github.com/heal-research/vstat";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
