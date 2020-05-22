{ stdenv, fetchurl
, openmpi
, cmake
, libxml2
, dyninst
, graphviz
, git
, gfortran
, python
}:

stdenv.mkDerivation {
  name = "must-1.6.0-rc1";
  src = fetchurl {
    url = "https://doc.itc.rwth-aachen.de/download/attachments/7373495/MUST-v1.6-rc1.tar.gz?version=1&modificationDate=1520357610000&api=v2";
    sha256 = "0pvrvcxh15r2ps7dvg1p88s8bg6c0s0rwin8a69c476l883qvz00";
    name = "MUST-v1.6-rc1.tar.gz";
  };
  nativeBuildInputs = [ cmake git python ];
  buildInputs = [
    gfortran
    openmpi
    libxml2 # for GTI
    dyninst # For more detailed error output
    graphviz # Another optional dependency is graphviz for graphical representations of deadlock and datatype error situations.
  ];

  meta = {
    homePage = "https://doc.itc.rwth-aachen.de/display/CCP/Project+MUST";
    description = "detects usage errors of the Message Passing Interface (MPI) and reports them to the user";
    # InsertCPredef(MUST_MPI_UB, MPI_UB, predefs, alignments, extents);
    # error: 'MPI_UB' was not declared in this scope
    broken = true;
  };
}
