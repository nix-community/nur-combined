{ stdenv, lib, fetchurl, gfortran, cmake, makeWrapper
, which, openssh, blas, lapack, mpi, boost, exatensor, python3
} :

assert
  lib.asserts.assertMsg
  (!blas.isILP64)
  "A 32 bit integer implementation of BLAS is required.";

stdenv.mkDerivation rec {
  pname = "dirac";
  version = "21.0";

  nativeBuildInputs = [
    which
    gfortran
    cmake
    python3
    makeWrapper
    openssh
  ];

  # For now, DIRAC is built without the PCMSolver optional dependency.
  buildInputs = [
    blas
    lapack
    boost
    exatensor
  ];

  propagatedBuildInputs = [
    mpi
  ];

  src = fetchurl {
    url = "https://zenodo.org/record/4836496/files/DIRAC-${version}-Source.tar.gz";
    sha256 = "0vqmin24xqkcp3rvml0dimc4kjmb3m37c3l6bkjy4y6d3xyb41yg";
  };

  patches = [
    ./0001-exatensor-cmake.patch
  ];

  postPatch = ''
    substituteInPlace ./cmake/custom/exatensor.cmake \
    --subst-var-by exatensor ${exatensor}

    patchShebangs .
  '';

  FC = "mpif90";
  CC = "mpicc";
  CXX = "mpicxx";
  MATH_ROOT = blas;
  ENABLE_EXATENSOR = "ON";

  /*
  Cmake is required to build but adding it to the buildinputs then ignores the
  setup script. Therefore i call the script here manually but cmake is invoked
  by setup.
  */

  configurePhase = ''
    ./setup --prefix=$out --mpi
  '';

  preBuild = ''
    cd build
  '';

  # Parallel building of the DIRAC package introduces all kinds of unpredictable
  # bugs when modules within a single folder depend on each other.
  # enableParallelBuilding = true;

  hardeningDisable = [ "format" ];
  doInstallCheck = true;

  /*
  Make the MPI stuff available to the DIRAC script by hard-coding the MPI path.
  Moving pam-dirac to pam to conform with the DIRAC manual. Usually there is a
  weird hack in the install.cmake to install pam into the bin folder.

  The pam script is just a Python script that sets a ton of ENV variables.
  */
  postFixup = ''
    mv $out/bin/pam-dirac $out/bin/pam

    substituteInPlace $out/bin/pam \
      --replace "find_executable('mpirun')" "'${mpi}/bin/mpirun'"
  '';

  # This is a small initial calculation to see whether everything works just fine.
  # http://diracprogram.org/doc/release-21/tutorials/getting_started.html
  installCheckPhase = ''
    cat > methanol.xyz << EOF
      6
      my first DIRAC calculation # anything can be in this line
      C       0.000000000000       0.138569980000       0.355570700000
      O       0.000000000000       0.187935770000      -1.074466460000
      H       0.882876920000      -0.383123830000       0.697839450000
      H      -0.882876940000      -0.383123830000       0.697839450000
      H       0.000000000000       1.145042790000       0.750208830000
      H       0.000000000000      -0.705300580000      -1.426986340000
    EOF

    cat > hf.inp <<-EOF
    **DIRAC
    .WAVE FUNCTION
    **WAVE FUNCTION
    .SCF
    **MOLECULE
    *BASIS
    .DEFAULT
    cc-pVDZ
    *END OF INPUT
    EOF

    $out/bin/pam --mpi=2 --mol=$(pwd)/methanol.xyz --inp=$(pwd)/hf.inp --scratch=$(pwd)
  '';

  passthru = { inherit mpi; };

  meta = with lib; {
    description = "The DIRAC program computes molecular properties using relativistic quantum chemical methods.";
    license = licenses.unfree;
    homepage = "https://diracprogram.org/";
    platforms = platforms.linux;
  };
}
