{ lib, stdenv, fetchFromGitHub, cmake, perl, gfortran, python
, boost, eigen, zlib
} :

stdenv.mkDerivation rec {
  pname = "pcmsolver";
  version = "1.3.0";

  nativeBuildInputs = [
    cmake
    gfortran
    python
    perl
  ];

  buildInputs = [
    boost
    eigen
    zlib
  ];

  src = fetchFromGitHub  {
    owner = "PCMSolver";
    repo = pname;
    rev = "v${version}";
    sha256= "0jrxr8z21hjy7ik999hna9rdqy221kbkl3qkb06xw7g80rc9x9yr";
  };

  cmakeFlags = [
    "-DENABLE_OPENMP=ON"
  ];

  hardeningDisable = [
    "format"
  ];

  meta = with lib; {
    description = "An API for the Polarizable Continuum Model";
    homepage = "https://pcmsolver.readthedocs.io/en/stable/";
    license = licenses.lgpl3;
    platforms = platforms.unix;
  };
}
