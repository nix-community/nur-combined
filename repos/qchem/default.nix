final: prev:

let

  cfg = if (builtins.hasAttr "qchem-config" prev.config) then
    (import ./cfg.nix) prev.config.qchem-config
  else
    (import ./cfg.nix) { allowEnv = true; }; # if no config is given allow env

  lib = prev.lib;

  optAVX = cfg.optAVX;

  #
  # Our package set
  #
  overlay = subset: extra: let
    super = prev;
    self = final."${subset}";
    callPackage = super.lib.callPackageWith (final // self);
    pythonOverrides = (import ./pythonPackages.nix) subset;

  in {
    # FIXME: workaround, remove when upstream openblas is fixed
    # see https://github.com/markuskowa/NixOS-QChem/issues/52
    # This cause a mass re-build
    # openblas known broken versions: 0.3.13
    openblas = super.openblas.overrideAttrs (x: {
      makeFlags = x.makeFlags ++ [ "NO_AVX512=1" ];
    });

    "${subset}" = {
      # For consistency: every package that is in nixpgs-opt.nix
      # + extra builds that should be exposed
      inherit (final)
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

      pkgs = final;


      inherit callPackage;

      #
      # Upstream overrides
      #

      # Define an ILP64 blas/lapack
      # This is still missing upstream
      blas-i8 = if final.blas.implementation != "amd-blis" then prev.blas.override { isILP64 = true; }
        else super.blas.override { isILP64 = true; blasProvider = super.openblas; };

      lapack-i8 = if final.lapack.implementation != "amd-libflame" then prev.lapack.override { isILP64 = true; }
        else super.lapack.override { isILP64 = true; lapackProvider = super.openblas; };

      fftw = final.fftw.overrideAttrs ( oldAttrs: {
        buildInputs = [ final.gfortran ];
      });

      fftw-mpi = self.fftw.overrideAttrs (oldAttrs: {
        configureFlags = oldAttrs.configureFlags ++ [
          "--enable-mpi"
          "MPICC=${self.mpi}/bin/mpicc"
          "MPIFC=${self.mpi}/bin/mpif90"
          "MPIF90=${self.mpi}/bin/mpif90"
        ];

        propagatedBuildInputs = [ self.mpi ];
      });

      # For molcas and chemps2
      hdf5-full = final.hdf5.override {
        cpp = true;
        inherit (final) gfortran;
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

      # Return null if x == null otherwise return the argument
      nullable = x: ret: if x == null then null else ret;

      #
      # Applications
      #
      bagel = callPackage ./pkgs/apps/bagel {
        inherit optAVX;
        boost = final.boost165;
      };

      bagel-serial = callPackage ./pkgs/apps/bagel { mpi = null; };

      cefine = self.nullable self.turbomole (callPackage ./pkgs/apps/cefine { });

      cfour = callPackage ./pkgs/apps/cfour { };

      chemps2 = callPackage ./pkgs/apps/chemps2 { };

      cp2k = callPackage ./pkgs/apps/cp2k {
        libxc = self.libxc4;  # patches are are required for libxc5
        inherit optAVX;
      };

      crest = callPackage ./pkgs/apps/crest { };

      dalton = callPackage ./pkgs/apps/dalton { };

      dkh = callPackage ./pkgs/apps/dkh { };

      dftd3 = callPackage ./pkgs/apps/dft-d3 { };

      ergoscf = callPackage ./pkgs/apps/ergoscf { };

      gaussview = callPackage ./pkgs/apps/gaussview { };

      gdma = callPackage ./pkgs/apps/gdma { };

      gpaw = super.python3.pkgs.toPythonApplication self.python3.pkgs.gpaw;

      i-pi = super.python3.pkgs.toPythonApplication self.python3.pkgs.i-pi;

      nwchem = callPackage ./pkgs/apps/nwchem {
        blas = self.blas-i8;
        lapack = self.lapack-i8;
      };

      mctdh = callPackage ./pkgs/apps/mctdh { };

      mesa-qc = callPackage ./pkgs/apps/mesa {
        gfortran = final.gfortran6;
      };

      molcas = self.molcas2102;

      molcas1809 = callPackage ./pkgs/apps/openmolcas/v18.09.nix { };

      molcas2102 = callPackage ./pkgs/apps/openmolcas/v21.02.nix { };

      mrcc = callPackage ./pkgs/apps/mrcc { };

      mt-dgemm = callPackage ./pkgs/apps/mt-dgemm { };

      multiwfn = callPackage ./pkgs/apps/multiwfn { };

      orca = callPackage ./pkgs/apps/orca { };

      osu-benchmark = callPackage ./pkgs/apps/osu-benchmark {
        # OSU benchmark fails with C++ binddings enabled
        mpi = self.mpi.overrideAttrs (x: {
          configureFlags = super.lib.remove "--enable-mpi-cxx" x.configureFlags;
        });
      };

      packmol = callPackage ./pkgs/apps/packmol { };

      pcmsolver = callPackage ./pkgs/apps/pcmsolver {};

      psi4 = super.python3.pkgs.toPythonApplication self.python3.pkgs.psi4;
      psi4Unstable = super.python3.pkgs.toPythonApplication self.python3.pkgs.psi4Unstable;

      qdng = callPackage ./pkgs/apps/qdng {
        protobuf=super.protobuf3_11;
      };

      sharc = self.sharcV2;

      sharc21 = self.sharcV21;

      sharcV2 = callPackage ./pkgs/apps/sharc {
        molcas = self.molcas;
        molpro = self.molpro12; # V2 only compatible with versions up to 2012
      };

      sharcV21 = callPackage ./pkgs/apps/sharc/21.nix {
        bagel = self.bagel-serial;
        molcas = self.molcas;
        molpro = self.molpro12; # V2 only compatible with versions up to 2012
        orca = self.orca;
        gaussian = if cfg.optpath != null then self.gaussian else null;
        turbomole = self.turbomole;
      };

      stream-benchmark = callPackage ./pkgs/apps/stream { };

      tinker = callPackage ./pkgs/apps/tinker { };

      travis-analyzer = callPackage ./pkgs/apps/travis-analyzer { };

      turbomole = callPackage ./pkgs/apps/turbomole { };

      vmd = callPackage ./pkgs/apps/vmd { };

      wfoverlap = callPackage ./pkgs/apps/wfoverlap { };

      xcfun = callPackage ./pkgs/lib/xcfun { };

      xtb = callPackage ./pkgs/apps/xtb {
        turbomole = null;
        cefine = null;
        orca = self.orca;
      };

      ### Python packages
      python3 = super.python3.override { packageOverrides=pythonOverrides self super; };
      python2 = super.python2.override { packageOverrides=pythonOverrides self super; };

      #
      # Libraries
      #

      libefp = callPackage ./pkgs/lib/libefp {};

      libint1 = callPackage ./pkgs/lib/libint/1.nix { };

      libint2 = callPackage ./pkgs/lib/libint { inherit optAVX; };

      libvdwxc = callPackage ./pkgs/lib/libvdwxc { };

      # libint configured for bagel
      # See https://github.com/evaleev/libint/wiki#bagel
      libint-bagel = callPackage ./pkgs/lib/libint { cfg = [
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

      libvori = callPackage ./pkgs/lib/libvori { };

      # libxc legacy version
      libxc4 = callPackage ./pkgs/lib/libxc { };

      mvapich = callPackage ./pkgs/lib/mvapich { };

      osss-ucx = callPackage ./pkgs/lib/osss-ucx { };

      sos = callPackage ./pkgs/lib/sos { };

      #
      # Utilities
      #

      writeScriptSlurm = callPackage ./builders/slurmScript.nix {};

      slurm-tools = callPackage ./pkgs/apps/slurm-tools {};

      # A wrapper to enforce license checkouts with slurm
      slurmLicenseWrapper = callPackage ./builders/licenseWrapper.nix { };

      # build bats tests
      batsTest = callPackage ./builders/batsTest.nix { };

      # build a benchmark script
      #benchmarkScript = callPackage ./builders/benchmark.nix { };

      # benchmark set builder
      benchmarks = callPackage ./benchmark/default.nix { };

      benchmarksets = callPackage ./tests/benchmark-sets.nix {
        inherit callPackage;
      };

      f2c = callPackage ./pkgs/apps/f2c { };

      tests = with self; {
        cfour = nullable cfour (callPackage ./tests/cfour { });
        cp2k = callPackage ./tests/cp2k { };
        bagel = callPackage ./tests/bagel { };
        bagel-bench = callPackage ./tests/bagel/bench-test.nix { };
        dalton = callPackage ./tests/dalton { };
        hpcg = callPackage ./tests/hpcg { };
        hpl = callPackage ./tests/hpl { };
        mesa-qc = nullable mesa-qc (callPackage ./tests/mesa { });
        molcas = callPackage ./tests/molcas { };
        molpro = nullable molpro (callPackage ./tests/molpro { });
        mrcc = nullable mrcc (callPackage ./tests/mrcc { });
        nwchem = callPackage ./tests/nwchem { };
        psi4 = callPackage ./tests/psi4 { };
        pyscf = callPackage ./tests/pyscf { };
        qdng = nullable qdng (callPackage ./tests/qdng { });
        dgemm = callPackage ./tests/dgemm { };
        stream = callPackage ./tests/stream { };
        turbomole = nullable turbomole (callPackage ./tests/turbomole { });
        xtb = callPackage ./tests/xtb { };
      };

      testFiles = let
        batsDontRun = self.batsTest.override { overrideDontRun = true; };
      in builtins.mapAttrs (n: v: v.override { batsTest = batsDontRun; })
        self.tests;

      # provide null molpro attrs in case there is no license
      molpro = null;
      molpro12 = null;
      molpro20 = null;
      molpro-ext = null;
    }  // lib.optionalAttrs (cfg.licMolpro != null) {

      #
      # Molpro packages
      #
      molpro = self.molpro20;

      molpro12 = callPackage ./pkgs/apps/molpro/2012.nix { token=cfg.licMolpro; };

      molpro20 = callPackage ./pkgs/apps/molpro { token=cfg.licMolpro; };

      molpro-ext = callPackage ./pkgs/apps/molpro/custom.nix { token=cfg.licMolpro; };

    } // lib.optionalAttrs (cfg.optpath != null) {
      #
      # Quirky packages that need to reside outside the nix store
      #
      gaussian = callPackage ./pkgs/apps/gaussian { inherit (cfg) optpath; };

      matlab = callPackage ./pkgs/apps/matlab { inherit (cfg) optpath; };

    } // extra;
  } // lib.optionalAttrs optAVX (
    import ./nixpkgs-opt.nix final super
    );

in
  overlay cfg.prefix { }
