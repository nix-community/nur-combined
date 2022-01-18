{ lib, stdenv, fetchFromGitHub, cmake, vectorclass }:

stdenv.mkDerivation rec {
  pname = "vstat";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "heal-research";
    repo = "vstat";
    rev = "79b9ba2d69fe14e9e16a10f35d4335ffa984f02d";
    sha256 = "sha256-GvWHlLuJd+9bzR017OYofZsYwH/nqVOr+KmiaEZcDmw=";
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
