{ stdenv, fetchFromGitHub, cmake, gfortran, perl
, blas, liblapack, boost
, netcdf, netcdffortran, hdf5
, matio
, x11
, python27
, python27Packages
, openmpi
, swig
, metis
, parmetis
, superlu
, suitesparse
, cppunit }:
#mumps

stdenv.mkDerivation rec {

    version = "12-12-1";
    name = "trilinos-release-${version}";
    
    src = fetchFromGitHub {
      owner = "trilinos";
      repo = "Trilinos";
      rev = "89b8c7f016c247568f7c9c1f32d250c8d2683de0";
      sha256 = "1smz3wlpfyjn0czmpl8bj4hw33p1zi9nnfygpsx7jl1523nypa1n";
    };

    buildInputs = [ parmetis cppunit suitesparse superlu metis perl cmake gfortran blas liblapack boost netcdf netcdffortran hdf5 matio x11 python27 python27Packages.numpy openmpi swig];
    
    cmakeFlags = [
      "-DCMAKE_INSTALL_PREFIX=$out"
      "-DTrilinos_INSTALL_INCLUDE_DIR=$out/include"
      "-DTrilinos_INSTALL_LIB_DIR=$out/lib"
      "-Drilinos_INSTALL_RUNTIME_DIR=$out/bin"
      "-Drilinos_INSTALL_EXAMPLE_DIR=$out/example"
      "-DCMAKE_CXX_COMPILER=mpic++"
      "-DCMAKE_C_COMPILER=mpicc"
      "-DCMAKE_Fortran_COMPILER=mpif90"
      "-DCMAKE_BUILD_TYPE=RelWithDebInfo"
      "-DBUILD_SHARED_LIBS=ON"
      "-DTPL_ENABLE_BLAS=ON"
      "-DTPL_ENABLE_Boost=ON"
      "-DTPL_ENABLE_Cholmod=ON"
      "-DTPL_ENABLE_CppUnit=ON"
      "-DTPL_ENABLE_LAPACK=ON"
      "-DTPL_ENABLE_METIS=ON"
      "-DTPL_ENABLE_MPI=ON"
      "-DTPL_ENABLE_MUMPS=OFF" # to test
      "-DTPL_ENABLE_ParMETIS=ON"
      "-DTPL_ENABLE_Pthread=OFF"
      "-DTPL_ENABLE_SCALAPACK=OFF" # !! "-DTPL_SCALAPACK_LIBRARIES="
      "-DTPL_ENABLE_Scotch=OFF"
      "-DTPL_ENABLE_SuperLU=OFF"  # !!  "-DTPL_SuperLU_INCLUDE_DIRS="
      "-DTPL_ENABLE_UMFPACK=ON"
      "-DTrilinos_ENABLE_Amesos2=OFF" #!!
      "-DTrilinos_ENABLE_Belos=ON"
      "-DTrilinos_ENABLE_Ifpack2=ON"
      "-DTrilinos_ENABLE_Kokkos=ON"
      "-DTrilinos_ENABLE_MueLu=ON"
      "-DTrilinos_ENABLE_OpenMP=ON"
      "-DTrilinos_ENABLE_Teuchos=ON"
      "-DTrilinos_ENABLE_Tpetra=ON"
      "-DTrilinos_ENABLE_AztecOO=OFF"
      "-DTrilinos_ENABLE_Galeri=OFF"
      "-DTrilinos_ENABLE_Ifpack=OFF"
      "-DTrilinos_ENABLE_Isorropia=OFF"
      "-DTrilinos_ENABLE_Thyra=OFF"
      "-DTrilinos_ENABLE_Zoltan=ON"
      "-DTrilinos_ENABLE_Zoltan2=ON"
      "-DTrilinos_ENABLE_EXPLICIT_INSTANTIATION=ON"
      "-DTpetra_INST_COMPLEX_DOUBLE=ON"
      "-DTpetra_INST_INT_LONG=OFF"
      "-DTpetra_INST_LONG_LONG=OFF"
      "-DTpetra_INST_INT_LONG_LONG=OFF"
      "-DTpetraKernels_ENABLE_Experimental=ON"
      "-DAmesos_ENABLE_EpetraExt=ON"
      "-DAmesos2_ENABLE_MUMPS=OFF" # !!
      "-DAmesos2_ENABLE_Epetra=OFF" #!!
      "-DAmesos2_ENABLE_EpetraExt=OFF" #!!
      "-DBelos_ENABLE_Epetra=ON"
      "-DBelos_ENABLE_EpetraExt=ON"
      "-DMueLu_ENABLE_Amesos=ON"
      "-DMueLu_ENABLE_Epetra=ON"
      "-DMueLu_ENABLE_EpetraExt=ON"
      "-DTeuchos_ENABLE_COMPLEX=ON"
      "-DTrilinos_ENABLE_TESTS=ON"
      "-DCMAKE_VERBOSE_MAKEFILE=ON"
    ];
    
    #enableParallelBuilding = true;
    #dochek = true;
    meta = {
    	 description = "A self-contained collection of software in Trilinos
         focused on one primary class of numerical methods.";
	 homepage = "https://trilinos.org/";
	 platforms = stdenv.lib.platforms.linux;
         broken = true; # needs parmetis which is unfree
    };
}
