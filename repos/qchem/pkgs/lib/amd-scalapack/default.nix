{ lib, stdenv, fetchFromGitHub, cmake, openssh
, gfortran, mpi, amd-blis, amd-libflame
} :


stdenv.mkDerivation rec {
  pname = "amd-scalapack";
  version = "3.0";

  src = fetchFromGitHub {
    owner = "amd";
    repo = "scalapack";
    rev = "${version}";
    sha256 = "0i45y7gl8r61sj9psa4yq298p0yxn4qsc884w7jdvbi84y4hbqjs";
  };

  patches = [
    # -cpp flag leaks into the CFLAGS, which leads to gcc failure
    ./fc-cpp.patch
  ];

  nativeBuildInputs = [ cmake openssh gfortran ];
  buildInputs = [ mpi amd-blis amd-libflame ];

  doCheck = true;

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_STATIC_LIBS=OFF"
    "-DUSE_F2C=ON"
    "-DUSE_DOTC_WRAPPER=ON"
    "-DCMAKE_Fortran_FLAGS=-cpp"
  ];

  # Increase individual test timeout from 1500s to 10000s because hydra's builds
  # sometimes fail due to this
  checkFlagsArray = [ "ARGS=--timeout 10000" ];

  preCheck = ''
    # make sure the test starts even if we have less than 4 cores
    export OMPI_MCA_rmaps_base_oversubscribe=1

    # Fix to make mpich run in a sandbox
    export HYDRA_IFACE=lo

    # Run single threaded
    export OMP_NUM_THREADS=1

    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH''${LD_LIBRARY_PATH:+:}`pwd`/lib
  '';

  meta = with lib; {
    homepage = "https://developer.amd.com/amd-aocl/scalapack/";
    description = "Linear algebra routines for parallel distributed memory machines optmized for AMD processors";
    license = licenses.bsd3;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ markuskowa ];
  };

}
