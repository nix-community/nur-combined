{ stdenv, fetchurl, mpi ,file }:
    
stdenv.mkDerivation rec {
  name = "osu-micro-benchmarks-${version}";
  version = "5.8";
  src = fetchurl {
    url = "https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-${version}.tgz";
    sha256 = "19a4wg0msipibkxsi8i0c34d07512yfaj2k37dxg5541ysdw690f";
  };

  buildInputs = [ mpi file ];

  configureFlags = [ "CC=mpicc" "CXX=mpicxx" ];

}
