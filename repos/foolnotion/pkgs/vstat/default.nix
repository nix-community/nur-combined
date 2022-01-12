{ lib, stdenv, fetchFromGitHub, cmake, vectorclass }:

stdenv.mkDerivation rec {
  pname = "vstat";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "heal-research";
    repo = "vstat";
    rev = "0a75abd21093322b38ec4dbe0c26aa4a729f1c31";
    sha256 = "sha256-sWHLMGdr5iztCdgne8zVfZTr3FlQzaosg1B8Rps0IEY=";
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
