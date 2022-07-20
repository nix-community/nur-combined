{ lib
, stdenv
, fetchFromGitHub
, gfortran
, llvmPackages
}:

stdenv.mkDerivation rec {
  pname = "radmc3d";
  version = "2.0";

  src = fetchFromGitHub {
    owner = "dullemond";
    repo = "radmc3d-2.0";
    rev = "d4b66a344f3fbb42c3f0dd5a62542514230b5cb9";
    sha256 = "sha256-z/m/ab7QtBMLlvwzJdAAT6cJCN0mAjwpUM9w1DvX1iQ=";
  };

  buildInputs = [ gfortran ] ++ lib.optional stdenv.isDarwin llvmPackages.openmp;

  buildPhase = ''
    cd src
    make
  '';

  installPhase = ''
    install -d $out/bin
    install radmc3d $out/bin
  '';

  meta = with lib; {
    description = "Code package for diagnostic radiative transfer calculations in astronomy and astrophysics";
    homepage = "https://www.ita.uni-heidelberg.de/~dullemond/software/radmc-3d/";
    license = licenses.unlicense;
    maintainers = with maintainers; [ smaret ];
  };
}
