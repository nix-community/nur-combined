self_: super:

let

  cfg = if (builtins.hasAttr "qchem-config" super.config) then
    (import ./cfg.nix) super.config.qchem-config
  else
  (import ./cfg.nix) { allowEnv = true; }; # if no config is given allow env

  lib = super.lib;

  optAVX = cfg.optAVX;


  #
  # Our package set
  #
  overlay = subset: extra: let
    self = self_."${subset}";
    callPackage = super.lib.callPackageWith (self_ // self);
    pythonOverrides = (import ./pythonPackages.nix) subset;

  in {
    "${subset}" = {
      # For consistency: every package that is in nixpgs-opt.nix
      # + extra builds that should be exposed
      inherit (self_)
        fftwSinglePrec
        hpl
        hpcg
        gromacs
        gromacsMpi
        gromacsDouble
        gromacsDoubleMpi
        mpi
        mkl
        molden
        libxsmm
        octopus
        quantum-espresso
        quantum-espresso-mpi
        scalapack
        siesta
        siesta-mpi;

      pkgs = self_;


      inherit callPackage;

      #
      # Upstream overrides
      #

      # Define an ILP64 blas/lapack
      # This is still missing upstream
      blas-i8 = if self_.blas.implementation != "amd-blis" then self_.blas.override { isILP64 = true; }
                else super.blas.override { isILP64 = true; blasProvider = super.openblas; };
      lapack-i8 = if self_.lapack.implementation != "amd-libflame" then self_.lapack.override { isILP64 = true; }
                else super.lapack.override { isILP64 = true; lapackProvider = super.openblas; };

      fftw = self_.fftw.overrideAttrs ( oldAttrs: {
        buildInputs = [ self_.gfortran ];
      });

      # For molcas and chemps2
      hdf5-full = self_.hdf5.override {
        cpp = true;
        inherit (self_) gfortran;
      };

      octave = (super.octaveFull.override {
        enableJava = true;
        jdk = super.jdk8;
        inherit (super)
          hdf5
          ghostscript
          glpk
          suitesparse
          gnuplot;
        }).overrideAttrs (x: { preCheck = "export OMP_NUM_THREADS=4"; });

      # Allow to provide a local download source for unfree packages
      requireFile = if cfg.srcurl == null then super.requireFile else
        { name, sha256, ... } :
        super.fetchurl {
          url = cfg.srcurl + "/" + name;
          sha256 = sha256;
        };

      #
      # Applications
      #
      bagel = callPackage ./bagel {
        blas = self.mkl; # bagel is not stable with openblas
        boost = self_.boost165;
        scalapack=null; withScalapack=true;
      };

      bagel-serial = callPackage ./bagel { mpi = null; blas = self.mkl; };

      chemps2 = callPackage ./chemps2 {};

      cp2k = callPackage ./cp2k {
        libxc = self.libxc4;  # patches are are required for libxc5
        inherit optAVX;
      };

      dkh = callPackage ./dkh {};

      dftd3 = callPackage ./dft-d3 {};

      ergoscf = callPackage ./ergoscf { };

      gaussview = callPackage ./gaussview { };

      nwchem = callPackage ./nwchem { blas=self.blas-i8; lapack=self.lapack-i8; };

      mctdh = callPackage ./mctdh { };

      #mctdh-mpi = self.mctdh.override { useMPI = true; } ;

      mesa-qc = callPackage ./mesa {
        gfortran = self_.gfortran6;
      };

      molcas = callPackage ./openmolcas { };

      molcas1911 = self.molcas;

      molcas2010 = callPackage ./openmolcas/v20.10.nix { };

      molcas2102 = callPackage ./openmolcas/v21.02.nix { };

      #molcasUnstable = callPackage ./openmolcas/unstable.nix {
      #  texLive = self_.texlive.combine { inherit (self_.texlive) scheme-basic epsf cm-super; };
      #};

      mt-dgemm = callPackage ./mt-dgemm { };

      orca = callPackage ./orca { };

      osu-benchmark = callPackage ./osu-benchmark {
        # OSU benchmark fails with C++ binddings enabled
        mpi = self.mpi.overrideAttrs (x: {
          configureFlags = super.lib.remove "--enable-mpi-cxx" x.configureFlags;
        });
      };

      pcmsolver = callPackage ./pcmsolver {};

      psi4 = super.python3.pkgs.toPythonApplication self.python3.pkgs.psi4;
      psi4Unstable = super.python3.pkgs.toPythonApplication self.python3.pkgs.psi4Unstable;

      qdng = callPackage ./qdng { protobuf=super.protobuf3_11; };

      sharc = self.sharcV2;

      sharc21 = self.sharcV21;

      sharcV1 = callPackage ./sharc/V1.nix {
        molcas = self.molcas;
        molpro = self.molpro12; # V1 only compatible with versions up to 2012
        useMolpro = if cfg.licMolpro != null then true else false;
      };

      sharcV2 = callPackage ./sharc {
        molcas = self.molcas;
        molpro = self.molpro12; # V2 only compatible with versions up to 2012
        useMolpro = if cfg.licMolpro != null then true else false;
      };

      sharcV21 = callPackage ./sharc/21.nix {
        bagel = self.bagel-serial;
        molcas = self.molcas;
        molpro = self.molpro12; # V2 only compatible with versions up to 2012
        useMolpro = if cfg.licMolpro != null then true else false;
        useOrca = if cfg.srcurl != null then true else false;
      };

      stream-benchmark = callPackage ./stream { };

      vmd = callPackage ./vmd {};

      multiwfn = callPackage ./multiwfn {};
      turbomole = callPackage ./turbomole {};



      ### Python packages
      python3 = super.python3.override { packageOverrides=pythonOverrides self super; };
      python2 = super.python2.override { packageOverrides=pythonOverrides self super; };

      #
      # Libraries
      #

      libcint3 = callPackage ./libcint { };

      libefp = callPackage ./libefp {};

      libint1 = callPackage ./libint/1.nix { };

      libint2 = callPackage ./libint { inherit optAVX; };

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
      ] ++ lib.optional optAVX "--enable-fma"
      ;};

      # legacy version
      libxc4 = callPackage ./libxc { };

      mvapich = callPackage ./mvapich { };

      osss-ucx = callPackage ./osss-ucx { };

      sos = callPackage ./sos { };
      #
      # Utilities
      #

      writeScriptSlurm = callPackage ./builders/slurmScript.nix {};

      slurm-tools = callPackage ./slurm-tools {};

      # A wrapper to enforce license checkouts with slurm
      slurmLicenseWrapper = callPackage ./builders/licenseWrapper.nix { };

      # build bats tests
      batsTest = callPackage ./builders/batsTest.nix { };

      # build a benchmark script
      #benchmarkScript = callPackage ./builders/benchmark.nix { };

      # benchmark set builder
      benchmarks = callPackage ./benchmark/default.nix { };

      benchmarksets = callPackage ./tests/benchmark-sets.nix { inherit callPackage; };

      f2c = callPackage ./f2c { };

      tests = {
        cp2k = callPackage ./tests/cp2k { };
        bagel = callPackage ./tests/bagel { };
        bagel-bench = callPackage ./tests/bagel/bench-test.nix { };
        hpcg = callPackage ./tests/hpcg { };
        hpl = callPackage ./tests/hpl { };
        mesa-qc = callPackage ./tests/mesa { };
        molcas = callPackage ./tests/molcas { };
        #molcasUnstable = callPackage ./tests/molcas { molcas=self.molcasUnstable; };
        nwchem = callPackage ./tests/nwchem { };
        psi4 = callPackage ./tests/psi4 { };
        qdng = callPackage ./tests/qdng { };
        dgemm = callPackage ./tests/dgemm { };
        stream = callPackage ./tests/stream { };
        turbomole = callPackage ./tests/turbomole { };
      }  // lib.optionalAttrs (cfg.licMolpro != null) {
        molpro = callPackage ./tests/molpro { };
      };

      testFiles = let
        batsDontRun = self.batsTest.override { overrideDontRun = true; };
      in builtins.mapAttrs (n: v: v.override { batsTest = batsDontRun; })
        self.tests;

    }  // lib.optionalAttrs (cfg.licMolpro != null) {

      #
      # Molpro packages
      #
      molpro = self.molpro20;

      molpro12 = callPackage ./molpro/2012.nix { token=cfg.licMolpro; };

      molpro15 = callPackage ./molpro/2015.nix { token=cfg.licMolpro; };

      molpro18 = callPackage ./molpro/2018.nix { token=cfg.licMolpro; };

      molpro19 = callPackage ./molpro/2019.nix { token=cfg.licMolpro; };

      molpro20 = callPackage ./molpro { token=cfg.licMolpro; };

      molpro-ext = callPackage ./molpro/custom.nix { token=cfg.licMolpro; };

    } // lib.optionalAttrs (cfg.optpath != null) {

      #
      # Quirky packages that need to reside outside the nix store
      #
      gaussian = callPackage ./gaussian { inherit (cfg) optpath; };

      matlab = callPackage ./matlab { inherit (cfg) optpath; };

    } // extra;
  } // lib.optionalAttrs optAVX (
    import ./nixpkgs-opt.nix self_ super
    );

in
  overlay cfg.prefix { }
