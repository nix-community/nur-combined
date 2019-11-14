{ stdenv, fetchurl, coreutils, openmpi, gcc }:

stdenv.mkDerivation rec {
  version = "1.0";
  name = "mpi-ping-${version}";

  src = fetchurl {
     url = "http://gitlab.mbb.univ-montp2.fr/lxdsingu/atelier-lxdsingu/raw/master/mpi-ping.c" ;
     sha256 = "08x6js5n65frayvwnym0xl47m2m1arr86bbh9c0skksa0ds2mj4k";
  };

  builder = [ ./mpi-ping_builder.sh ];

  inherit  coreutils openmpi gcc;

}
