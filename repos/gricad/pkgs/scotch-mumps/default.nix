{ lib, stdenv, fetchurl, bison, openmpi, flex, zlib}:

stdenv.mkDerivation rec {
  version = "6.0.5a";
  name = "scotch-${version}";
  src_name = "scotch_${version}";

  buildInputs = [ bison openmpi flex zlib ];

  src = fetchurl {
    url = "https://gforge.inria.fr/frs/download.php/latestfile/298/${src_name}.tar.gz";
    sha256 = "0vsmgjz8qv80di3ljmc7hbdsizxxxwy2b9rgd2fl1mdc6dgbj8av";
  };

  sourceRoot = "${src_name}/src";

  preConfigure = ''
    ln -s Make.inc/Makefile.inc.x86-64_pc_linux2 Makefile.inc
  '';

  buildFlags = [ "scotch ptscotch esmumps ptesmumps" ];
  installFlags = [ "prefix=\${out}" ];

  installPhase = ''
    mkdir $out
    make install prefix=$out
    cp ../lib/*mumps* $out/lib/
  '';

  meta = {
    description = "Graph and mesh/hypergraph partitioning, graph clustering, and sparse matrix ordering";
    longDescription = ''
      Scotch is a software package for graph and mesh/hypergraph partitioning, graph clustering, 
      and sparse matrix ordering.
    '';
    homepage = http://www.labri.fr/perso/pelegrin/scotch;
    license = lib.licenses.cecill-c;
    maintainers = [ lib.maintainers.bzizou ];
    platforms = lib.platforms.linux;
  };
}

