{ stdenv, fetchurl
, blas ? openblas, openblas
, mpi ? openmpi, openmpi
}:

stdenv.mkDerivation {
  name = "hpl-2.3.1";
  src = fetchurl {
    url = "http://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz";
    sha256 = "0c18c7fzlqxifz1bf3izil0bczv3a7nsv0dn6winy3ik49yw3i9j";
  };
  buildInputs = [ blas mpi ];
  meta = {
    description = "A Portable Implementation of the High-Performance Linpack";
  };
}
