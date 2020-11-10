{ stdenv, fetchFromGitHub, python, gfortran, openblasCompat
, fftw, libint2, libxc, mpi, gsl, scalapack, openssh, makeWrapper
, libxsmm, spglib, which
, optAVX ? false
} :

let
  version = "7.1.0";

  cp2kVersion = "psmp";
  arch = "Linux-x86-64-gfortran";

in stdenv.mkDerivation rec {
  name = "cp2k-${version}";

  src = fetchFromGitHub {
    owner = "cp2k";
    repo = "cp2k";
    rev = "v${version}";
    sha256 = "0icmzqc9v8rvcw8xg295qpa7h3d1vpjbc89l0lvakam977ianblf";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ python which openssh makeWrapper ];
  buildInputs = [ gfortran fftw gsl libint2 libxc libxsmm  spglib openblasCompat mpi scalapack ];

  makeFlags = [
    "ARCH=${arch}"
    "VERSION=${cp2kVersion}"
  ];

  doCheck = true;

  enableParallelBuilding = true;

  postPatch = ''
    patchShebangs tools exts/dbcsr/tools/build_utils
  '';

  preConfigure = ''
    cat > arch/${arch}.${cp2kVersion} << EOF
    CC         = gcc
    CPP        =
    FC         = mpif90
    LD         = mpif90
    AR         = ar -r
    DFLAGS     = -D__FFTW3 -D__LIBXC -D__LIBINT -D__parallel -D__SCALAPACK \
                 -D__MPI_VERSION=3 -D__F2008 -D__LIBXSMM -D__SPGLIB \
                 -D__MAX_CONTR=4

    FCFLAGS    = \$(DFLAGS) -O2 -ffree-form -ffree-line-length-none \
                 -ftree-vectorize -funroll-loops -msse2 \
                 ${stdenv.lib.optionalString optAVX "-mavx -mavx2"} \
                 -std=f2008 \
                 -fopenmp -ftree-vectorize -funroll-loops \
                 -I${libxc}/include -I${libxsmm}/include \
                 -I${libint2}/include
    LIBS       = -lfftw3 -lfftw3_threads -lscalapack -lopenblas \
                 -lxcf03 -lxc -lxsmmf -lxsmm -lsymspg \
                 -lint2 -lstdc++ \
                 -fopenmp
    LDFLAGS    = \$(FCFLAGS) \$(LIBS)
    EOF
  '';

  checkPhase = ''
    export OMP_NUM_THREADS=1
    export OMPI_MCA_rmaps_base_oversubscribe=1
    export CP2K_DATA_DIR=data

    mpirun -np 2 exe/${arch}/libcp2k_unittest.${cp2kVersion}
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/cp2k

    cp exe/${arch}/* $out/bin

    for i in cp2k cp2k_shell graph; do
      makeWrapper $out/bin/$i.${cp2kVersion} $out/bin/$i --set CP2K_DATA_DIR $out/share/cp2k
    done

    cp -r data/* $out/share/cp2k

    ln -s ${mpi}/bin/mpirun $out/bin/mpirun
    ln -s ${mpi}/bin/mpiexec $out/bin/mpiexec
  '';

  meta = with stdenv.lib; {
    description = "Quantum chemistry and solid state physics program";
    homepage = "https://www.cp2k.org";
    license = licenses.gpl3;
    maintainers = [ maintainers.markuskowa ];
    platforms = [ "x86_64-linux" ];
  };
}

