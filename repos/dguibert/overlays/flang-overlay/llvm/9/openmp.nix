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
    rev = "release_90";
    sha256 = "sha256-VLlEFH13Te1MdRbhw5mqcw6z0FNThAXGSfb3rWiRa6s=";
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
