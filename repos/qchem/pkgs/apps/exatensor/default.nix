{ stdenv, lib, fetchFromGitLab, blas, mpi } :

let
  version = "2020-07-15";

in stdenv.mkDerivation rec {
  pname = "exatensor";
  inherit version;

  src = fetchFromGitLab {
    owner = "DmitryLyakh";
    repo = pname;
    rev = "d304c03b7289525f250245ece1b4a13a5973fef4";
    sha256 = "0zlqwpdqfycwvys39lvvj94cprhaxmyaxxs1c66f10dazjbafp49";
  };

  buildInputs = [ blas.passthru.provider ];

  MPILIB = if (mpi.pname == "openmpi") then "OPENMPI"
    else if (mpi.pname == "mpich") then "MPICH"
    else throw "Only openmpi and mpich supported by ${pname}.";

  PATH_OPENMPI = mpi;
  PATH_MPICH = mpi;

  BLASLIB =
    if (blas.passthru.implementation == "openblas") then "OPENBLAS"
    else if (blas.passthru.implementation == "mkl") then "MKL"
    else throw "Only MKL and OPENBLAS supported by ${pname}.";

  PATH_BLAS_OPENBLAS = blas.passthru.provider;
  PATH_BLAS_MKL = blas.passthru.provider;
  PATH_BLAS_MKL_DEP = "${blas.passthru.provider}/lib";
  PATH_BLAS_MKL_INC = "${blas.passthru.provider}/include";

  installPhase = ''
    mkdir -p $out/lib $out/bin $out/include
    cp -r ./bin/* $out/bin
    cp -r ./lib/* $out/lib
    cp -r ./include/* $out/include
  '';

  meta = with lib; {
    description = "ExaTENSOR is a basic numerical tensor algebra library for
distributed HPC systems equipped with multicore CPU and NVIDIA or AMD GPU.";
    homepage = https://gitlab.com/DmitryLyakh/ExaTensor;
    license = licenses.lgpl3Only;
    platforms = platforms.linux;
  };
}

