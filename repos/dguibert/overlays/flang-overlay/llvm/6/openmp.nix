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
    rev = "release_60";
    sha256 = "1c8j12344j434fdndmx46kd0habm7jl5lrj29wmsffnc12x9fknf";
  };

  nativeBuildInputs = [cmake perl];
  buildInputs = [llvm python gfortran hwloc];

  cmakeFlags = [
    "-DCMAKE_CXX_FLAGS=-std=c++11"
    "-DLIBOMP_FORTRAN_MODULES=on"
    "-DLIBOMP_USE_HWLOC=on"
  ];

  preConfigure = "sourceRoot=$PWD/openmp-*/runtime";

  enableParallelBuilding = true;

  meta = {
    description = "Components required to build an executable OpenMP program";
    homepage = http://openmp.llvm.org/;
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
}
