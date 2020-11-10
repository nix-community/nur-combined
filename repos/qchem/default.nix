self: super:

let

  cfg = if (builtins.hasAttr "qchem-config" super.config) then
    super.config.qchem-config
  else
    (import ./cfg.nix) { allowEnv = true; };

  # build a package with specfific MPI implementation
  withMpi = pkg : mpi :
    super.appendToName mpi.name (pkg.override { mpi = mpi; });

  # Build a whole package set for a specific MPI implementation
  makeMpi = pkg: MPI: with super; {
    mpi = pkg;

    globalarrays = super.globalarrays.override { openmpi=pkg; };

    osu-benchmark = callPackage ./osu-benchmark { mpi=pkg; };

    # scalapack is only valid with ILP32
    scalapack = (super.scalapack.override { mpi=pkg; }).overrideAttrs
    ( x: {
      CFLAGS = super.lib.optionalString cfg.optAVX  "-O3 -mavx2 -mavx -msse2";
      FFLAGS = super.lib.optionalString cfg.optAVX  "-O3 -mavx2 -mavx -msse2";
    });

    scalapackCompat = MPI.scalapack;

    cp2k = callPackage ./cp2k {
      mpi=pkg;
      scalapack=MPI.scalapack;
      fftw=self.fftwOpt;
      optAVX = cfg.optAVX;
    };

    # MKL is the default. Relativistic methods are broken with non-MKL libs
    bagel-mkl = callPackage ./bagel { blas = self.mkl; mpi=pkg; boost=boost165; scalapack=null; withScalapack=true; };
    bagel-openblas = callPackage ./bagel { blas = self.openblas; mpi=pkg; };
    bagel-mkl-scl = callPackage ./bagel { blas = self.mkl; mpi=pkg; scalapack=MPI.scalapack; withScalapack = true; };
    bagel = MPI.bagel-mkl;

    hpl = super.hpl.override { mpi=pkg; };

    mctdh = callPackage ./mctdh { useMPI=true; mpi=pkg; scalapack=MPI.scalapack; };

    nwchem = callPackage ./nwchem { mpi=pkg; };

    openmolcasUnstable = callPackage ./openmolcas/unstable.nix {
      texLive = texlive.combine { inherit (texlive) scheme-basic epsf cm-super; };
      mpi=pkg;
      globalarrays=MPI.globalarrays;
    };
  };

  pythonOverrides = import ./pythonPackages.nix;

in with super;
{
  # Place composed config in pkgs
  config.qchem-config = cfg;

  # Allow to provide a local download source for unfree packages
  requireFile = if cfg.srcurl == null then super.requireFile else
    { name, sha256, ... } :
    super.fetchurl {
      url = cfg.srcurl + "/" + name;
      sha256 = sha256;
    };

  # MPI packages sets
  openmpiPkgs = makeMpi self.openmpi self.openmpiPkgs;

  # OSU benchmark fails with C++ binddings enabled
  openmpiPkgsNoCpp = makeMpi (self.openmpi.overrideAttrs (x: {
    configureFlags = super.lib.remove "--enable-mpi-cxx" x.configureFlags;
  })) self.openmpiPkgs;

  mpichPkgs = makeMpi self.mpich2 self.mpichPkgs;

  mvapichPkgs = makeMpi self.mvapich self.mvapichPkgs;

  openmpi = super.openmpi.overrideAttrs (x: {
    buildInputs = x.buildInputs ++ [ self.ucx ];
    # Supress compiler error accordig to ucx's instructions
    # https://github.com/openucx/ucx/wiki/OpenMPI-and-OpenSHMEM-installation-with-UCX#running-open-mpi-with-ucx
    configureFlags = x.configureFlags ++ [ "--enable-mca-no-build=btl-uct" ];
  });

  ### Quantum Chem
  chemps2 = callPackage ./chemps2 {};

  cp2k = self.openmpiPkgs.cp2k;

  bagel = self.openmpiPkgs.bagel;

  bagel-serial = callPackage ./bagel { mpi = null; blas = self.mkl; };

  gaussian = callPackage ./gaussian { inherit (cfg) optpath; };

  gaussview = callPackage ./gaussview { };

  ergoscf = callPackage ./ergoscf { };

  # fix a bug in the header file, which causes bagel to fail
  libxc = super.libxc.overrideDerivation (oa: {
    postFixup = ''
      sed -i '/#include "config.h"/d' $out/include/xc.h
    '';
  });

  nwchem = self.openmpiPkgs.nwchem;

  mctdh = callPackage ./mctdh { mpi=null; };

  mctdh-mpi = self.openmpiPkgs.mctdh;

  mesa-qc = callPackage ./mesa {
    gfortran = gfortran6;
  };

  molpro = self.molpro20;

  molpro12 = callPackage ./molpro/2012.nix { token=cfg.licMolpro; };

  molpro15 = callPackage ./molpro/2015.nix { token=cfg.licMolpro; };

  molpro18 = callPackage ./molpro/2018.nix { token=cfg.licMolpro; };

  molpro19 = callPackage ./molpro/2019.nix { token=cfg.licMolpro; };

  molpro20 = callPackage ./molpro { token=cfg.licMolpro; };

  molcas = callPackage ./openmolcas { };

  molcas1911 = self.molcas;

  molcas2010 = callPackage ./openmolcas/v20.10.nix { };

  # deactivate for now, does not build out of the box
  #molcasUnstable = self.openmpiPkgs.openmolcasUnstable;
  molcasUnstable = self.molcas2010;

  orca = callPackage ./orca { };

  qdng = callPackage ./qdng { fftw=self.fftwOpt; protobuf=protobuf3_11; };

  sharc = self.sharcV2;

  sharc21 = self.sharcV21;

  sharcV1 = callPackage ./sharc/V1.nix {
    molcas = self.molcas;
    molpro = self.molpro12; # V1 only compatible with versions up to 2012
    useMolpro = if cfg.licMolpro != null then true else false;
    fftw = self.fftwOpt;
  };

  sharcV2 = callPackage ./sharc {
    molcas = self.molcas;
    molpro = self.molpro12; # V2 only compatible with versions up to 2012
    useMolpro = if cfg.licMolpro != null then true else false;
    fftw = self.fftwOpt;
  };

  sharcV21 = callPackage ./sharc/21.nix {
    bagel = self.bagel-serial;
    molcas = self.molcas;
    molpro = self.molpro12; # V2 only compatible with versions up to 2012
    useMolpro = if cfg.licMolpro != null then true else false;
    useOrca = if cfg.srcurl != null then true else false;
    fftw = self.fftwOpt;
  };

  vmd = callPackage ./vmd {};

  # Unsuported. Scalapack does not work with ILP64
  # scalapack = callPackage ./scalapack { mpi=self.openmpi-ilp64; };

  ## Other scientfic applicatons

  matlab = callPackage ./matlab { inherit (cfg) optpath; };


  octave = (super.octave.override {
    enableQt = true;
    enableJava = true;
    jdk = super.jdk8;
    inherit (super)
      hdf5
      ghostscript
      glpk
      suitesparse
      gnuplot;
    inherit (super.libsForQt5)
      qscintilla;
    inherit (super.qt5)
      qtbase
      qttools
      qtscript
      qtsvg;
  }).overrideAttrs (x: { preCheck = "export OMP_NUM_THREADS=4"; });

  ### Python packages

  python3 = super.python3.override { packageOverrides=pythonOverrides; };
  python2 = super.python2.override { packageOverrides=pythonOverrides; };


  ### Optmized HPC libs

  # Provide an optimized fftw library.
  # fftw supports instruction autodetect
  # Overriding fftw completely causes a mass rebuild!
  fftwOpt = fftw.overrideDerivation ( oldAttrs: {
    configureFlags = oldAttrs.configureFlags
    ++ [
      "--enable-avx"
      "--enable-avx2"
      "--enable-fma"
      "--enable-avx-128-fma"
    ];
    buildInputs = [ self.gfortran ];
  });

  # For molcas and chemps2
  hdf5-full = hdf5.override {
    cpp = true;
    inherit gfortran;
  };

  ### HPC libs and Tools

  hwloc-x11 = super.hwloc.override { x11Support= true; };

  mt-dgemm = callPackage ./mt-dgemm { };

  libcint = callPackage ./libcint { };

  libint2 = callPackage ./libint { optAVX = cfg.optAVX; };

  # Needed for CP2K
  libint1 = callPackage ./libint/1.nix { };


  # libint configured for bagel
  # See https://github.com/evaleev/libint/wiki#bagel
  libint-bagel = callPackage ./libint { cfg = [
    "--enable-eri=1"
    "--enable-eri3=1"
    "--enable-eri2=1"
    "--with-max-am=6"
    "--with-eri3-max-am=6"
    "--with-eri2-max-am=6"
    "--disable-unrolling"
    "--enable-generic-code"
    "--with-cartgauss-ordering=bagel"
    "--enable-contracted-ints"
  ] ++ lib.optional cfg.optAVX "--enable-fma"
  ;};

  libxsmm = callPackage ./libxsmm { optAVX = cfg.optAVX; };

  mvapich = callPackage ./mvapich { };

  openshmem = callPackage ./openshmem { };

  openshmem-smp = self.openshmem;

  openshmem-udp = callPackage ./openshmem { conduit="udp"; };

  openshmem-ibv = callPackage ./openshmem { conduit="ibv"; };

  openshmem-ofi = callPackage ./openshmem { conduit="ofi"; };

  osss-ucx = callPackage ./osss-ucx { };

  sos = callPackage ./sos { };

  spglib = callPackage ./spglib {};

  stream-benchmark = callPackage ./stream { };

  ucx = callPackage ./ucx { enableOpt=true; };

  # Utilities
  writeScriptSlurm = callPackage ./builders/slurmScript.nix {};

  slurm-tools = callPackage ./slurm-tools {};

  # A wrapper to enforce license checkouts with slurm
  slurmLicenseWrapper = callPackage ./builders/licenseWrapper.nix { };

  # build bats tests
  batsTest = callPackage ./builders/batsTest.nix { };

  # build a benchmark script
  benchmarkScript = callPackage ./builders/benchmark.nix { };

  # benchmark set builder
  qc-benchmarks = callPackage ./benchmark/default.nix { };

  qc-benchmarksets = callPackage ./tests/benchmark-sets.nix { };

  qc-tests = {
    molpro = callPackage ./tests/molpro { };
    cp2k = callPackage ./tests/cp2k { };
    bagel = callPackage ./tests/bagel { };
    bagel-bench = callPackage ./tests/bagel/bench-test.nix { };
    hpcg = callPackage ./tests/hpcg { };
    hpl = callPackage ./tests/hpl { };
    mesa-qc = callPackage ./tests/mesa { };
    molcas = callPackage ./tests/molcas { };
    molcasUnstable = callPackage ./tests/molcas { molcas=self.molcasUnstable; };
    nwchem = callPackage ./tests/nwchem { };
    qdng = callPackage ./tests/qdng { };
    dgemm = callPackage ./tests/dgemm { };
    stream = callPackage ./tests/stream { };
  };

  qc-testFiles = let
    batsDontRun = self.batsTest.override { overrideDontRun = true; };
  in builtins.mapAttrs (n: v: v.override { batsTest = batsDontRun; })
    self.qc-tests;
}


