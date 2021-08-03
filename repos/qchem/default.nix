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
    "${subset}" = {
      # For consistency: every package that is in nixpgs-opt.nix
      # + extra builds that should be exposed
      inherit (final)
        cp2k
        fftwSinglePrec
        hpl
        hpcg
        gromacs
        gromacsMpi
        gromacsDouble
        gromacsDoubleMpi
        i-pi
        libint
        mpi
        mkl
        molden
        libxsmm
        octopus
        quantum-espresso
        quantum-espresso-mpi
        pcmsolver
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

      crest = callPackage ./pkgs/apps/crest { };

      dalton = callPackage ./pkgs/apps/dalton { };

      dkh = callPackage ./pkgs/apps/dkh { };

      dftd3 = callPackage ./pkgs/apps/dft-d3 { };

      ergoscf = callPackage ./pkgs/apps/ergoscf { };

      gaussview = callPackage ./pkgs/apps/gaussview { };

      gdma = callPackage ./pkgs/apps/gdma { };

      gpaw = super.python3.pkgs.toPythonApplication self.python3.pkgs.gpaw;

      harminv = callPackage ./pkgs/apps/harminv { };

      nwchem = callPackage ./pkgs/apps/nwchem {
        blas = self.blas-i8;
        lapack = self.lapack-i8;
      };

      mctdh = callPackage ./pkgs/apps/mctdh { };

      meep = super.python3.pkgs.toPythonApplication self.python3.pkgs.meep;

      mesa-qc = callPackage ./pkgs/apps/mesa {
        gfortran = final.gfortran6;
      };

      molcas = self.molcas2106;

      molcas1809 = callPackage ./pkgs/apps/openmolcas/v18.09.nix { };

      molcas2106 = callPackage ./pkgs/apps/openmolcas/default.nix { };

      mrcc = callPackage ./pkgs/apps/mrcc { };

      mt-dgemm = callPackage ./pkgs/apps/mt-dgemm { };

      multiwfn = callPackage ./pkgs/apps/multiwfn { };

      gmultiwfn = callPackage ./pkgs/apps/gmultiwfn { };

      openmm = super.python3.pkgs.toPythonApplication self.python3.pkgs.openmm;

      orca = callPackage ./pkgs/apps/orca { };

      osu-benchmark = callPackage ./pkgs/apps/osu-benchmark {
        # OSU benchmark fails with C++ binddings enabled
        mpi = self.mpi.overrideAttrs (x: {
          configureFlags = super.lib.remove "--enable-mpi-cxx" x.configureFlags;
        });
      };

      packmol = callPackage ./pkgs/apps/packmol { };

      psi4 = super.python3.pkgs.toPythonApplication self.python3.pkgs.psi4;
      psi4Unstable = super.python3.pkgs.toPythonApplication self.python3.pkgs.psi4Unstable;

      pysisyphus = super.python3.pkgs.toPythonApplication self.python3.pkgs.pysisyphus;

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

      vmd = if cfg.useCuda
        then callPackage ./pkgs/apps/vmd/binary.nix { }
        else callPackage ./pkgs/apps/vmd { }
      ;

      wfoverlap = callPackage ./pkgs/apps/wfoverlap { };

      xtb = callPackage ./pkgs/apps/xtb {
        turbomole = null;
        cefine = null;
        orca = self.orca;
      };

      ### Python packages
      python3 = super.python3.override { packageOverrides=pythonOverrides cfg self super; };
      python2 = super.python2.override { packageOverrides=pythonOverrides cfg self super; };

      #
      # Libraries
      #

      libctl = callPackage ./pkgs/lib/libctl {};

      libefp = callPackage ./pkgs/lib/libefp {};

      libGDSII = callPackage ./pkgs/lib/libGDSII {};

      libint1 = callPackage ./pkgs/lib/libint/1.nix { };

      libvdwxc = callPackage ./pkgs/lib/libvdwxc { };

      # libxc legacy version
      libxc4 = callPackage ./pkgs/lib/libxc { };

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

      # Provide null gaussian attrs in case optpath is not set
      gaussian = null;
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
