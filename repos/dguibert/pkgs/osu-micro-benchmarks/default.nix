{
  stdenv,
  fetchurl,
  mpi ? openmpi,
  openmpi,
}:
stdenv.mkDerivation {
  name = "osu-micro-benchmarks-5.6.2";

  src = fetchurl {
    url = "http://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-5.6.2.tar.gz";
    sha256 = "15bvzjdf7zvhs9jpq09zgmjr8w4d8j96swf04dl7i62kv2mr1jrf";
  };

  buildInputs = [mpi];

  configureFlags = [
    "CC=${mpi}/bin/mpicc"
    "CXX=${mpi}/bin/mpicxx"
  ];

  enableParallelBuilding = true;
  doCheck = true;

  postInstall = ''
    mkdir $out/bin
    ln -s $out/libexec/osu-micro-benchmarks/mpi/*/* $out/bin
  '';
}
