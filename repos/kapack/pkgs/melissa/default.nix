{ stdenv, lib, fetchFromGitHub, cmake, gfortran, python37, zeromq, openmpi}:

stdenv.mkDerivation rec {
  name =  "melissa-${version}";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "melissa-sa";
    repo = "melissa";
    rev = "c8608e1a64bb823d711d8dfa1d831d0db43c8a40";
    sha256 = "1wfvwryfcy9166zp6ndmdnv1ybdkjnkl5y5lbprdfjb7ipv4a8ph";
  };

  buildInputs = [ cmake gfortran python37 zeromq openmpi];

  enableParallelBuilding = false;

  meta = with lib; {
    homepage = "https://melissa-sa.github.io/";
    description = "Melissa is a file avoiding, adaptive, fault tolerant and elastic framework, to run large scale sensitivity analysis on supercomputers";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
