final: prev:
with final; {
  lib = prev.lib.extend (import ./lib);

  adapters = import ./pkgs/stdenv/adapters.nix prev;
  inherit
    (final.adapters)
    optimizePackage
    optimizedStdEnv
    customFlags
    extraNativeCflags
    customFlagsWithinStdEnv
    ;

  # some-qt5-package = prev.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
  inherit
    (final.callPackages ./pkgs/elfutils {
      lib = final.lib;
      elfutils = prev.elfutils;
    })
    elfutils_0_179
    ;

  dyninst = final.callPackage ./pkgs/dyninst {};
  palabos = final.callPackage ./pkgs/palabos {};
  otf2 = final.callPackage ./pkgs/otf2 {};

  score-p = final.callPackage ./pkgs/score-p {
    inherit (final) otf2;
    inherit (final) cubew;
    inherit (final) cubelib;
  };

  libffi_3_2 = final.callPackage ./pkgs/libffi/3.2.nix {};

  gotcha = final.callPackage ./pkgs/gotcha {};

  caliper = final.callPackage ./pkgs/caliper {
    inherit (final) dyninst;
  };

  caliper-cuda = final.caliper.override {
    enableCuda = true;
  };

  drvFlavor = drv: let
    name = builtins.head (builtins.concatLists (map (x: builtins.match x drv.name) [
      "(.*)-[0-9.]*" # fallback regex
    ]));
    flavor =
      if drv == null
      then "none"
      else "${name}";
  in
    builtins.trace "drvFlavor: ${
      if (drv != null)
      then drv
      else "null"
    }=${flavor}"
    flavor;

  compilers_line = stdenv: mpi: let
    compiler_id = drvFlavor stdenv.cc.cc;
    mpi_id = drvFlavor mpi;
    line =
      {
        intel-compilers = {
          intelmpi = "CC=mpiicc CXX=mpiicpc F77=mpiifort FC=mpiifort";
          openmpi = "CC=mpicc CXX=mpicxx F77=mpif90 FC=mpif90";
          none = "CC=icc CXX=icpc F77=ifort FC=ifort";
        };
        oneapi-compilers = {
          none = "CC=icx CXX=icpx FC=ifx";
          openmpi = "CC=mpicc CXX=mpicxx FC=mpif90";
          oneapi-mpi = "CC=mpiicc CXX=mpiicpc FC=mpiifort";
        };
        aocc = {
          none = "CC=clang CXX=clang++ FC=flang";
          openmpi = "CC=mpicc CXX=mpicxx FC=mpif90";
        };
        gcc = {
          openmpi = "CC=mpicc CXX=mpicxx FC=mpif90";
          none = "";
        };
      }
      ."${compiler_id}"
      ."${mpi_id}";
  in
    builtins.trace "compilers ${compiler_id}.${mpi_id}: ${line}" line;

  collectl = final.callPackage ./pkgs/collectl {};

  cubew = final.callPackage ./pkgs/cubew {};
  cubelib = final.callPackage ./pkgs/cubelib {};
  cubegui = final.callPackage ./pkgs/cubegui {inherit (final) cubelib;};
  arm-forge = libsForQt5.callPackage ./pkgs/arm-forge {};

  dwm = prev.dwm.override {
    patches = [
      ./pkgs/dwm/0001-dwm-pertag-20170513-ceac8c9.patch
      ./pkgs/dwm/0002-dwm-systray-20180314-3bd8466.diff.patch
      ./pkgs/dwm/0003-config.h-azerty.patch
      ./pkgs/dwm/0004-config.h-audio-controls.patch
      ./pkgs/dwm/0005-light-solarized-theme.patch
      ./pkgs/dwm/0006-config-support-shortcuts-for-vbox-inside-windows.patch
      ./pkgs/dwm/0007-xpra-as-float.patch
      ./pkgs/dwm/0008-qtpass-as-float.patch
      ./pkgs/dwm/0009-pineentry-as-float.patch
    ];
  };

  fetchannex = final.callPackage ./pkgs/build-support/fetchannex {git-annex = prev.git-annex;};
  # throw "use gitAndTools.hub instead"
  git-credential-password-store = final.callPackage ./pkgs/git-credential-password-store {};

  jobs = final.callPackage ./pkgs/jobs {
    inherit final prev;
    inherit (final) stream;
    admin_scripts_dir = "";
  };

  hpcg = final.callPackage ./pkgs/hpcg {};
  inherit
    (final.callPackages ./pkgs/hpl {
      inherit (final) fetchannex;
    })
    hpl_netlib_2_3
    hpl_mkl_netlib_2_3
    hpl_cuda_ompi_volta_pascal_kepler_3_14_19
    ;

  lmod = final.callPackage ./pkgs/lmod {
    inherit (prev.luaPackages) luafilesystem;
    inherit (final) luaposix;
  };
  luaposix = final.callPackage ./pkgs/luaposix {};

  lo2s = final.callPackage ./pkgs/lo2s {inherit (final) otf2;};
  lulesh = final.callPackage ./pkgs/lulesh {};

  gccNoOffloadPtx = final.callPackage ./pkgs/gcc/9 {
    cudaSupport = false;
    noSysDirs = true;

    # PGO seems to speed up compilation by gcc by ~10%, see #445 discussion
    profiledCompiler = with stdenv; (!isDarwin && (isi686 || isx86_64));

    enableLTO = !stdenv.isi686;

    libcCross =
      if stdenv.targetPlatform != stdenv.buildPlatform
      then libcCross
      else null;
    threadsCross =
      if stdenv.targetPlatform != stdenv.buildPlatform
      then threadsCross
      else null;

    isl =
      if !stdenv.isDarwin
      then isl_0_17
      else null;
  };

  gcc9OffloadPtx = final.callPackage ./pkgs/gcc/9 {
    cudaSupport = true;
    nvidia_x11 = linuxPackages.nvidia_x11;

    noSysDirs = true;

    # PGO seems to speed up compilation by gcc by ~10%, see #445 discussion
    profiledCompiler = with stdenv; (!isDarwin && (isi686 || isx86_64));

    enableLTO = !stdenv.isi686;

    libcCross =
      if stdenv.targetPlatform != stdenv.buildPlatform
      then libcCross
      else null;
    threadsCross =
      if stdenv.targetPlatform != stdenv.buildPlatform
      then threadsCross
      else null;

    isl =
      if !stdenv.isDarwin
      then isl_0_17
      else null;
  };

  gcc10OffloadPtx = final.callPackage ./pkgs/gcc/10 {
    cudaSupport = true;
    nvidia_x11 = linuxPackages.nvidia_x11;
    langFortran = true;

    noSysDirs = true;

    # PGO seems to speed up compilation by gcc by ~10%, see #445 discussion
    profiledCompiler = with stdenv; (!isDarwin && (isi686 || isx86_64));

    enableLTO = !stdenv.isi686;

    libcCross =
      if stdenv.targetPlatform != stdenv.buildPlatform
      then libcCross
      else null;
    threadsCross =
      if stdenv.targetPlatform != stdenv.buildPlatform
      then threadsCross
      else null;

    isl =
      if !stdenv.isDarwin
      then isl_0_17
      else null;
  };

  gnumake_slurm = prev.gnumake.overrideAttrs (attrs: {
    patches =
      (attrs.patches or [])
      ++ [
        ./pkgs/make/make-4.2.slurm.patch
        #(pkgs.fetchpatch {
        #   url = "https://raw.githubusercontent.com/SchedMD/slurm/master/contribs/make-4.0.slurm.patch";
        #   sha256 = "1rnwcw6xniwq6d0qpbz1b15bzmkl6r9zj20m6jnivif8qd7gkjqf";
        #   stripLen = 1;
        #})
      ];
  });

  hpcbind = final.callPackage ./pkgs/hpcbind {};

  maqao = final.callPackage ./pkgs/maqao {};

  modulefile = final.callPackage ./pkgs/gen-modulefile {};

  must = final.callPackage ./pkgs/must {inherit (final) dyninst;};
  muster = final.callPackage ./pkgs/muster {};

  nemo_gyre_36 = final.callPackage ./pkgs/nemo/3.6.nix {};

  nemo_bench_4_0 = final.callPackage ./pkgs/nemo/4.0.nix {};
  nemo_gyre_pisces_4_0 = final.callPackage ./pkgs/nemo/4.0.nix {config = "GYRE_PISCES";};

  nemo_bench_4_0_2 = final.callPackage ./pkgs/nemo/4.0.2.nix {};
  nemo_gyre_pisces_4_0_2 = final.callPackage ./pkgs/nemo/4.0.2.nix {config = "GYRE_PISCES";};

  #inherit (final.callPackages ./pkgs/nemo { })
  #  nemo_meto_go8_4_0_2
  #;

  nss_sss = callPackage ./pkgs/sssd/nss-client.nix {};

  nvptx-newlib = final.callPackage ./pkgs/nvptx-newlib {};
  nvptx-tools = final.callPackage ./pkgs/nvptx-tools {};

  inherit
    (final.callPackages ./pkgs/openmpi {
      enableSlurm = true;
      lib = final.lib;
      openmpi = prev.openmpi;
    })
    openmpi_2_0_2
    openmpi_4_0_2
    openmpi_4_1_1
    ;

  osu-micro-benchmarks = final.callPackage ./pkgs/osu-micro-benchmarks {};

  # https://github.com/NixOS/nixpkgs/issues/44426
  python27 = prev.python27.override {packageOverrides = final.pythonOverrides;};
  python35 = prev.python35.override {packageOverrides = final.pythonOverrides;};
  python36 = prev.python36.override {packageOverrides = final.pythonOverrides;};
  python37 = prev.python37.override {packageOverrides = final.pythonOverrides;};
  python38 = prev.python38.override {packageOverrides = final.pythonOverrides;};
  python39 = prev.python39.override {packageOverrides = final.pythonOverrides;};
  python310 = prev.python310.override {packageOverrides = final.pythonOverrides;};

  pythonOverrides = python-self: python-super:
    with python-self; {
      hatchet = callPackage ./pkgs/py-hatchet {};
      pyslurm = final.lib.upgradeOverride python-super.pyslurm (oldAttrs: rec {
        name = "${oldAttrs.pname}-${version}";
        version = "19-05-0";
      });

      pyslurm_17_02_0 = (python-super.pyslurm.override {slurm = slurm_17_02_11;}).overrideAttrs (oldAttrs: rec {
        name = "${oldAttrs.pname}-${version}";
        version = "17.02.0";

        patches = [];

        preConfigure = ''
          sed -i -e 's@__max_slurm_hex_version__ = "0x11020a"@__max_slurm_hex_version__ = "0x11020b"@' setup.py
        '';

        src = prev.fetchFromGitHub {
          repo = "pyslurm";
          owner = "PySlurm";
          # The release tags use - instead of .
          rev = "refs/heads/17.02.0";
          sha256 = "sha256:1b5xaq0w4rkax8y7rnw35fapxwn739i21dgb9609hg01z9b6n1ka";
        };
      });
      pyslurm_17_11_12 = (python-super.pyslurm.override {slurm = final.slurm_17_11_9_1;}).overrideAttrs (oldAttrs: rec {
        name = "${oldAttrs.pname}-${version}";
        version = "17.11.12";

        patches = [];

        src = prev.fetchFromGitHub {
          repo = "pyslurm";
          owner = "PySlurm";
          # The release tags use - instead of .
          rev = "${builtins.replaceStrings ["."] ["-"] version}";
          sha256 = "01xdx2v3w8i3bilyfkk50f786fq60938ikqp2ls2kf3j218xyxmz";
        };
      });
      pyslurm_19_05_0 = (python-super.pyslurm.override {slurm = final.slurm_19_05_5;}).overrideAttrs (oldAttrs: rec {
        name = "${oldAttrs.pname}-${version}";
        version = "19.05.0";

        patches = [];

        src = prev.fetchFromGitHub {
          repo = "pyslurm";
          owner = "PySlurm";
          # The release tags use - instead of .
          rev = "${builtins.replaceStrings ["."] ["-"] version}";
          sha256 = "sha256-WdCs1hs5cUp/iYM6Rtyk29XNHNOfBqvK99okHxAmy9E=";
        };
      });
      mpi4py = builtins.trace "mpi4py without check" python-super.mpi4py.overrideAttrs (oldAttrs: {
        doCheck = false;
        doInstallCheck = false;
      });
    };

  ravel = final.callPackage ./pkgs/ravel {
    inherit (final) otf2;
    inherit (final) muster;
  };
  inherit
    (final.callPackages ./pkgs/slurm {
      gtk2 = null;
      lib = final.lib;
      slurm = prev.slurm;
    })
    slurm_17_02_11
    slurm_17_11_5
    slurm_17_11_9_1
    slurm_18_08_5
    slurm_19_05_3_2
    slurm_19_05_5
    ;
  st = prev.st.override {
    patches = [
      ./pkgs/st/0001-theme-from-base16-c_header.patch
      ./pkgs/st/0002-Show-bold-not-as-bright.patch
      (prev.fetchpatch {
        url = "https://st.suckless.org/patches/clipboard/st-clipboard-20180309-c5ba9c0.diff";
        sha256 = "sha256:1gsqgasc5spklrk7575m7jlxcii072wf03qn9znqwh1ibsy9lnr2";
      })
    ];
  };
  xios_10 = final.callPackage ./pkgs/xios/1.0.nix {};
  xios = final.callPackage ./pkgs/xios {};

  # miniapps
  miniapp-ping-pong = final.callPackage ./pkgs/miniapp-ping-pong {};
  stream = final.callPackage ./pkgs/stream {};
  test-dgemm = final.callPackage ./pkgs/test-dgemm {};
}
