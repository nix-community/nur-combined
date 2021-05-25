{ stdenv, lib, fetchgit, gfortran, cmake, makeWrapper
, which, openssh, blas, lapack, mpi, python3
} :

assert
  lib.asserts.assertMsg
  (!blas.isILP64)
  "A 32 bit integer implementation of BLAS is required.";

stdenv.mkDerivation rec {
  pname = "dalton";
  version = "2020.0";

  nativeBuildInputs = [
    gfortran
    cmake
    python3
    makeWrapper
  ];

  buildInputs = [
    blas
    lapack
  ];

  propagatedBuildInputs = [
    mpi
    which
  ];

  # Many submodules are required and they are not fetched by fetchFromGitLab.
  src = fetchgit  {
    url = "https://gitlab.com/dalton/dalton.git";
    rev = "66052b3af5ea7225e31178bf9a8b031913c72190"; # Git hash of 2020.0 as of 25.05.2021.
    sha256 = "1n32f6rxk80i6lsx2j08bf2kmzj9cgx8fh4q7kkgnn2agimhv2v6";
    deepClone = true;
  };

  postPatch = "patchShebangs .";

  FC = "mpif90";
  CC = "mpicc";
  CXX = "mpicxx";

  /*
  Cmake is required to build but adding it to the buildinputs then ignores the setup script.
  Therefore i call the script here manually but cmake is invoked by setup.
  */
  configurePhase = ''
    ./setup --prefix=$out --mpi && cd build
  '';

  enableParallelBuilding = true;

  hardeningDisable = [ "format" ];

  /*
  Dalton does not care about bin lib share directory structures and puts everything in a single
  directory. Clean up the mess here.
  */
  postInstall = ''
    mkdir -p $out/bin $out/share/dalton
    for exe in dalton dalton.x; do
      mv $exe $out/bin/.
    done

    for dir in basis tools; do
      mv $dir $out/share/dalton/.
    done

    substituteInPlace $out/bin/dalton \
      --replace 'INSTALL_BASDIR=$SCRIPT_DIR/basis' "INSTALL_BASDIR=$out/share/dalton/basis"

    rm -rf $out/dalton
  '';

  /*
  Make the MPI stuff available to the Dalton script. Direct exposure of MPI is not necessary.
  */
  postFixup = ''
    wrapProgram $out/bin/dalton \
      --prefix PATH : ${mpi}/bin \
      --prefix PATH : ${which}/bin \
      --prefix PATH : ${openssh}/bin

    wrapProgram $out/bin/dalton.x \
      --prefix PATH : ${mpi}/bin \
      --prefix PATH : ${which}/bin \
      --prefix PATH : ${openssh}/bin
  '';

  passthru = { inherit mpi; };

  meta = with lib; {
    description = "Quantum chemistry code specialised on exotic properties.";
    license = licenses.lgpl21Only;
    homepage = "https://daltonprogram.org/";
    platforms = platforms.linux;
  };
}
