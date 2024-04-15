{
  stdenv,
  lib,
  fetchFromGitHub,
  openmpi,
  mpi ? openmpi,
  suffix ? "",
}:
stdenv.mkDerivation {
  name = "lulesh-2.0.3";

  src = fetchFromGitHub {
    owner = "LLNL";
    repo = "LULESH";
    rev = "refs/tags/2.0.3";
    sha256 = "0w3lsds2h812zni5z9blpfj4gfadz9n0727qnjf5q60sf6ps96l3";
  };

  buildInputs = [mpi];

  configurePhase = ''
    ${lib.optionalString stdenv.cc.isIntel or false ''
      export MACHINE=-xCORE-AVX2
      make MPICXX="mpiicpc -DUSE_MPI=1" SERCXX="icpc -DUSE_MPI=0" CXXFLAGS="-g -O3 $MACHINE -qopenmp -I. -Wall" LDFLAGS="-g -O3 $MACHINE -qopenmp"
    ''}
    ${lib.optionalString stdenv.cc.isGNU or false ''
      make MPICXX="mpicxx -DUSE_MPI=1" SERCXX="g++ -DUSE_MPI=0" CXXFLAGS="-g -O3 -fopenmp -I. -Wall" LDFLAGS="-g -O3 -fopenmp"
    ''}
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp lulesh2.0 $out/bin/lulesh2.0${suffix}
  '';
}
