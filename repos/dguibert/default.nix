# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ versions ? import ./versions.nix
, nixpkgs ? { outPath = versions.nixpkgs; revCount = 123456; shortRev = "gfedcba"; }
, pkgs ? import nixpkgs {}
}:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  envs = if (builtins.pathExists ./envs/.decrypted) then import ./envs { } else {};

  adapters = import ./pkgs/stdenv/adapters.nix pkgs;
  inherit (adapters) optimizePackage
                     withOpenMP
		     optimizedStdEnv
		     customFlags
		     extraNativeCflags
		     customFlagsWithinStdEnv;

  example-package = pkgs.callPackage ./pkgs/example-package { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
  dyninst = pkgs.callPackage ./pkgs/dyninst { };
  palabos = pkgs.callPackage ./pkgs/palabos { };
  otf2 = pkgs.callPackage ./pkgs/otf2 { };

  score-p = pkgs.callPackage ./pkgs/score-p {
    inherit otf2;
    inherit cubew;
    inherit cubelib;
  };
  caliper = pkgs.callPackage ./pkgs/caliper {
    inherit dyninst;
  };

  compilers_line = stdenv: mpi: let
    compiler_id = if (stdenv.cc.isIntel or false) then "intel" else "gnu";
    mpi_id = if (mpi.isIntel or false) then "intel" else
             if (mpi != null) then "openmpi" else "none";
  in {
      intel = {
        intel = "CC=mpiicc CXX=mpiicpc F77=mpiifort FC=mpiifort";
        openmpi = "CC=mpicc CXX=mpicxx F77=mpif90 FC=mpif90";
        none = "CC=icc CXX=icpc F77=ifort FC=ifort";
      };
      gnu = {
        openmpi = "CC=${mpi}/bin/mpicc";
        none = "";
      };
    }."${compiler_id}"."${mpi_id}";

  cubew = pkgs.callPackage ./pkgs/cubew { };
  cubelib = pkgs.callPackage ./pkgs/cubelib { };
  cubegui = pkgs.callPackage ./pkgs/cubegui { inherit cubelib; };
  dwm = pkgs.dwm.override {patches = [
    ./pkgs/dwm/0001-dwm-pertag-20170513-ceac8c9.patch
    ./pkgs/dwm/0002-dwm-systray-20180314-3bd8466.diff.patch
    ./pkgs/dwm/0003-config.h-azerty.patch
    ./pkgs/dwm/0004-config.h-audio-controls.patch
    ./pkgs/dwm/0005-light-solarized-theme.patch
    ./pkgs/dwm/0006-config-support-shortcuts-for-vbox-inside-windows.patch
    ./pkgs/dwm/0007-xpra-as-float.patch
    ./pkgs/dwm/0008-qtpass-as-float.patch
    ./pkgs/dwm/0009-pineentry-as-float.patch
  ];};

  fetchannex = pkgs.callPackage ./pkgs/build-support/fetchannex { git-annex = gitAndTools.git-annex; };
  # throw "use gitAndTools.hub instead"
  gitAndTools = (removeAttrs pkgs.gitAndTools ["hubUnstable"]) // {
    git-credential-password-store = pkgs.callPackage ./pkgs/git-credential-password-store { };
  };

  jobs = pkgs.callPackage ./pkgs/jobs {
    inherit stream;
    #scheduler = jobs.scheduler_slurm;
    admin_scripts_dir = "";
    scheduler = jobs.scheduler_local;
  };

  hpcg = pkgs.callPackage ./pkgs/hpcg { };
  hpl = pkgs.callPackage ./pkgs/hpl { };

  lmod = pkgs.callPackage ./pkgs/lmod {
      inherit (pkgs.luaPackages) luafilesystem;
      inherit luaposix;
  };
  luaposix = pkgs.callPackage ./pkgs/luaposix { };

  lo2s = pkgs.callPackage ./pkgs/lo2s { inherit otf2; };
  lulesh = pkgs.callPackage ./pkgs/lulesh { };

  gnumake_slurm = pkgs.gnumake.overrideAttrs (attrs: {
    patches = (attrs.patches or []) ++ [
       ./pkgs/make/make-4.2.slurm.patch
       #(pkgs.fetchpatch {
       #   url = "https://raw.githubusercontent.com/SchedMD/slurm/master/contribs/make-4.0.slurm.patch";
       #   sha256 = "1rnwcw6xniwq6d0qpbz1b15bzmkl6r9zj20m6jnivif8qd7gkjqf";
       #   stripLen = 1;
       #})
    ];
  });

  hdf5 = pkgs.callPackage ./pkgs/hdf5 {
    gfortran = null;
    szip = null;
    mpi = null;
    inherit compilers_line;
  };

  mkEnv = { name ? "env"
          , buildInputs ? []
          , ...
        }@args: let name_=name;
                    args_ = builtins.removeAttrs args [ "name" "buildInputs" "shellHook" ];
        in pkgs.stdenv.mkDerivation (rec {
    name = "${name_}-env";
    phases = [ "buildPhase" ];
    postBuild = "ln -s ${env} $out";
    env = pkgs.buildEnv { name = name; paths = buildInputs; ignoreCollisions = true; };
    inherit buildInputs;
    shellHook = ''
      export ENVRC=${name_}
      source ~/.bashrc
    '' + (args.shellHook or "");
  } // args_);

  modulefile = pkgs.callPackage ./pkgs/gen-modulefile { };

  must = pkgs.callPackage ./pkgs/must { inherit dyninst; };
  muster = pkgs.callPackage ./pkgs/muster { };
  nemo_36 = pkgs.callPackage ./pkgs/nemo/3.6.nix { xios = xios_10; };
  nemo = pkgs.callPackage ./pkgs/nemo { inherit xios; };

  netcdf = pkgs.callPackage ./pkgs/netcdf { inherit compilers_line; };

  nix-patchtools = pkgs.callPackage ./pkgs/nix-patchtools { };

  openmpi = builtins.trace "openmpi" (pkgs.callPackage ./pkgs/openmpi { });

  ravel = pkgs.callPackage ./pkgs/ravel {
    inherit otf2;
    inherit muster;
  };
  slurm_17_11_5 = pkgs.callPackage ./pkgs/slurm/17.11.5.nix { gtk2 = null; };
  st = pkgs.st.override {patches = [
    ./pkgs/st/0001-theme-from-base16-c_header.patch
    #./pkgs/st/0002-Update-base-patch-to-0.8.1.patch
    ./pkgs/st/0003-Show-bold-not-as-bright.patch
    (pkgs.fetchpatch { url="https://st.suckless.org/patches/clipboard/st-clipboard-20180309-c5ba9c0.diff"; sha256="1f7fgzvbiikdm98icmh34abjha361nvf6a9r7lq38lhnwlyw12a9"; })
  ];};
  xios_10 = pkgs.callPackage ./pkgs/xios/1.0.nix { };
  xios = pkgs.callPackage ./pkgs/xios { };

  # miniapps
  miniapp-ping-pong = pkgs.callPackage ./pkgs/miniapp-ping-pong { inherit caliper; };
  stream = pkgs.callPackage ./pkgs/stream { };
  test-dgemm = pkgs.callPackage ./pkgs/test-dgemm { };

}

