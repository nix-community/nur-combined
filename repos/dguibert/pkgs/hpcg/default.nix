{
  stdenv,
  fetchFromGitHub,
  blas ? openblas,
  openblas,
  mpi ? openmpi,
  openmpi,
}:
stdenv.mkDerivation {
  name = "hpcg-3.0.0.45-g5455949";
  src = fetchFromGitHub {
    owner = "hpcg-benchmark";
    repo = "hpcg";
    rev = "5455949cac0a2edf5be71cd29cc9b16e3007a7ce";
    sha256 = "0wf3hdi4y4scc3cphfjfx3ywcakvynf2gkkf2qjhbily9cl2553p";
  };

  buildInputs = [mpi];

  phases = ["unpackPhase" "buildPhase"];
  buildPhase = ''
    make arch=Linux_MPI CXX=mpicxx
    mkdir -p $out/bin

    cp -v bin/* $out/bin
  '';
}
