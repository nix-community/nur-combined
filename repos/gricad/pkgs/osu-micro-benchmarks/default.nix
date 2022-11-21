{ stdenv, fetchurl, mpi ,file }:
    
stdenv.mkDerivation rec {
  name = "osu-micro-benchmarks-${version}";
  version = "7.0";
  src = fetchurl {
    url = "https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-${version}.tar.gz";
    sha256 = "01l3y3vg0li58in05xngvr3m8dz0rsd4dhxagd6j8jiskypjz3lm";
  };

  buildInputs = [ mpi file ];

  configureFlags = [ "CC=mpicc" "CXX=mpicxx" ];

}
