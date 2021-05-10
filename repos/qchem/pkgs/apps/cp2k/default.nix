{ lib, stdenv, fetchFromGitHub, python3, gfortran, mkl
, fftw, libint2, libvori, libxc, mpi, gsl, scalapack, openssh, makeWrapper
, libxsmm, spglib, which
, optAVX ? false
} :

let
  version = "8.1.0";

  cp2kVersion = "psmp";
  arch = "Linux-x86-64-gfortran";

in stdenv.mkDerivation rec {
  name = "cp2k-${version}";

  src = fetchFromGitHub {
    owner = "cp2k";
    repo = "cp2k";
    rev = "v${version}";
    sha256 = "1qv7gprmm9riz9jj82n0mh2maij137h3ivh94z22bnm75az86jcs";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ python3 which openssh makeWrapper ];
  buildInputs = [
    gfortran
    fftw
    gsl
    libint2
    libvori
    libxc
    libxsmm
    spglib
    mpi
    scalapack
    mkl
  ];

  makeFlags = [
    "ARCH=${arch}"
    "VERSION=${cp2kVersion}"
  ];

  doCheck = true;

  enableParallelBuilding = true;

  postPatch = ''
    patchShebangs tools exts/dbcsr/tools/build_utils exts/dbcsr/.cp2k
    substituteInPlace exts/dbcsr/.cp2k/Makefile --replace '/usr/bin/env python3' '${python3}/bin/python'
  '';

  configurePhase = ''
    cat > arch/${arch}.${cp2kVersion} << EOF
    CC         = mpicc
    CPP        =
    FC         = mpif90
    LD         = mpif90
    AR         = ar -r
    DFLAGS     = -D__FFTW3 -D__LIBXC -D__LIBINT -D__parallel -D__SCALAPACK \
                 -D__MPI_VERSION=3 -D__F2008 -D__LIBXSMM -D__SPGLIB \
                 -D__MAX_CONTR=4 -D__LIBVORI

    CFLAGS    = -fopenmp
    FCFLAGS    = \$(DFLAGS) -O2 -ffree-form -ffree-line-length-none \
                 -ftree-vectorize -funroll-loops -msse2 \
                 ${lib.optionalString optAVX "-mavx -mavx2"} \
                 -std=f2008 \
                 -fopenmp -ftree-vectorize -funroll-loops \
                 -I${libxc}/include -I${libxsmm}/include \
                 -I${libint2}/include
    LIBS       = -lfftw3 -lfftw3_threads \
                 -lscalapack -lmkl_gf_lp64 -lmkl_gnu_thread -lmkl_core \
                 -lxcf03 -lxc -lxsmmf -lxsmm -lsymspg \
                 -lint2 -lstdc++ -lvori \
                 -lgomp -lpthread -lm \
                 -fopenmp
    LDFLAGS    = \$(FCFLAGS) \$(LIBS)
    EOF
  '';

  checkPhase = ''
    export OMP_NUM_THREADS=1
    # Fix to make mpich run in a sandbox
    export HYDRA_IFACE=lo
    export OMPI_MCA_rmaps_base_oversubscribe=1
    export CP2K_DATA_DIR=data

    mpirun -np 2 exe/${arch}/libcp2k_unittest.${cp2kVersion}
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/cp2k

    cp exe/${arch}/* $out/bin

    for i in cp2k cp2k_shell graph; do
      wrapProgram $out/bin/$i.${cp2kVersion} \
        --set-default CP2K_DATA_DIR $out/share/cp2k
    done

    # Is always built.
    wrapProgram $out/bin/cp2k.popt \
      --set-default CP2K_DATA_DIR $out/share/cp2k \
      --set OMP_NUM_THREADS 1

    cp -r data/* $out/share/cp2k

    ln -s ${mpi}/bin/mpirun $out/bin/mpirun
    ln -s ${mpi}/bin/mpiexec $out/bin/mpiexec
  '';

  passthru = { inherit mpi; };

  meta = with lib; {
    description = "Quantum chemistry and solid state physics program";
    homepage = "https://www.cp2k.org";
    license = licenses.gpl3;
    maintainers = [ maintainers.markuskowa ];
    platforms = [ "x86_64-linux" ];
  };
}
