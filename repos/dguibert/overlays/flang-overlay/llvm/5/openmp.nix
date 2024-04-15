{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  llvm,
  version,
  perl,
  python,
  gfortran,
  hwloc,
}:
stdenv.mkDerivation {
  name = "openmp-${version}";

  src = fetchFromGitHub {
    owner = "llvm-mirror";
    repo = "openmp";
    rev = "release_50";
    sha256 = "0jnhp0lp6xhi18m2bk9qjvnqg80rsaqyp3b6s629xh084bf8ifv4";
  };

  buildInputs = [cmake llvm perl python gfortran hwloc];

  cmakeFlags = [
    "-DCMAKE_CXX_FLAGS=-std=c++11"
    "-DLIBOMP_FORTRAN_MODULES=on"
    "-DLIBOMP_USE_HWLOC=on"
  ];

  preConfigure = "sourceRoot=$PWD/openmp-*/runtime";

  enableParallelBuilding = true;

  meta = {
    description = "An OpenMP runtime for the llvm compiler";
    homepage = http://llvm.org/;
    license = lib.licenses.ncsa;
    platforms = lib.platforms.all;
  };
}
