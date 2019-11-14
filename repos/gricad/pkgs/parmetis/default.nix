{stdenv, fetchurl, gfortran, openmpi, cmake}:

stdenv.mkDerivation rec {
  version = "4.0.3";
  name = "parmetis-${version}";
  
  src = fetchurl {
    url = "http://glaros.dtc.umn.edu/gkhome/fetch/sw/parmetis/${name}.tar.gz";
    sha256 = "0pvfpvb36djvqlcc3lq7si0c5xpb2cqndjg8wvzg35ygnwqs5ngj";
  };
  
  cmakeFlags = [
    "-DCMAKE_CXX_COMPILER=mpicxx"
    "-DCMAKE_C_COMPILER=mpicc"
    "-DMETIS_PATH=../metis"
    "-DGKLIB_PATH=../metis/GKlib"
    "-DCMAKE_VERBOSE_MAKEFILE=1"
    "-DSHARED=TRUE"
    ];    
  #  "-DMPI_INCLUDE_PATH=${openmpi}/include"

  buildInputs = [ gfortran cmake openmpi ];
  
  configurePhase = ''make config prefix=$out'';

  installPhase = ''make install'';

  meta = {
    homepage = "http://glaros.dtc.umn.edu/gkhome/metis/parmetis/overview";
    description = "ParMETIS - Parallel Graph Partitioning and
    Fill-reducing Matrix Ordering";    
    longDescription = "ParMETIS is an MPI-based parallel library that
    implements a variety of algorithms for partitioning unstructured graphs,
    meshes, and for computing fill-reducing orderings of sparse matrices.
    ParMETIS extends the functionality provided by METIS and includes
    routines that are especially suited for parallel AMR computations and
    large scale numerical simulations.";
    maintainers = [ stdenv.lib.maintainers.ltavard ];
    platforms = stdenv.lib.platforms.unix;
  };
}
