{ stdenv
, fetchurl
, openblasCompat
, python
, gfortran
, openmpi
, tcsh
, valgrind
, suitesparse
, hwloc
, metis
, hdf5
, netcdf
, scalarType ? "complex" # May be "real" or "complex"
, zlib
}:

stdenv.mkDerivation rec {
  name = "petsc-${version}";
  version = "3.11.1";

  src = fetchurl {
    url = "http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-${version}.tar.gz";
    sha256 = "08zvy44w4ilygwshwnrvmgryrwd5i6gihf7kpgml05ffyycpyqnb";
  };

  patches = [ ./petscmpiexec.patch ];

  buildInputs = [ 
    openblasCompat
    python
    gfortran
    openmpi
    tcsh
    valgrind
    suitesparse
    hwloc
    metis
    hdf5
    netcdf
    zlib
  ];

  enableParallelBuilding = true;

  preConfigure = ''
    patchShebangs .
  '';

  configureFlags = let
    sharedLibraryExtension = if stdenv.isDarwin then ".dylib" else ".so";
  in [
      "--with-scalar-type=${scalarType}"
      "--with-debugging=0"
      "--with-mpi=1"
      # PETSc is not threadsafe, disable pthread/openmp (see http://www.mcs.anl.gov/petsc/miscellaneous/petscthreads.html)
      "--with-pthread=0"
      "--with-openmp=0"
      "--with-ssl=0"
      "--with-x=0"
      "--with-mpi-dir=${openmpi}"
      "--with-blas-lapack-lib=${openblasCompat}/lib/libopenblas${sharedLibraryExtension}"
      "--with-valgrind=1"
      "--with-valgrind-dir=${valgrind}"
      "--with-suitesparse-dir=${suitesparse}"
      "--with-hwloc-dir=${hwloc.lib}"
      "--with-netcdf-dir=${netcdf}"
      "--with-hdf5-dir=${hdf5}"
      "--with-metis-dir=${metis}"
      "--with-zlib-dir=${zlib}"
      "--with-64-bit-indices=1"
  ];

  postInstall = ''
    rm -f $out/bin/uncrustify.cfg
    rm -rf $out/bin/win32fe
  '';

  doCheck = true;

  meta = {
    description = "Library of linear algebra algorithms for solving partial differential equations";
    homepage = https://www.mcs.anl.gov/petsc/index.html;
    platforms = stdenv.lib.platforms.all;
    license = stdenv.lib.licenses.bsd2;
  };
}
