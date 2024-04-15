{
  stdenv,
  lib,
  fetchurl,
  makeOverridable,
  blas ? openblas,
  openblas,
  openmpi,
  fetchannex,
  nvidia_x11 ? linuxPackages.nvidia_x11,
  linuxPackages,
  cudatoolkit_10_1,
  openmpi_3_1 ? openmpi,
  mkl,
  nix-patchtools,
  glibc,
  gcc48,
  callPackage,
}: let
  common = {
    name ? "hpl-${version}",
    version ? "2.3",
    src ?
      fetchurl {
        url = "http://www.netlib.org/benchmark/hpl/hpl-2.3.tar.gz";
        sha256 = "0c18c7fzlqxifz1bf3izil0bczv3a7nsv0dn6winy3ik49yw3i9j";
      },
    buildInputs ? [],
    LAlib ? "-lblas",
    MPlib ? "-lmpi",
    ...
  } @ args: let
    extraArgs = builtins.removeAttrs args ["name" "version" "src" "buildInputs"];
  in
    callPackage ({
      stdenv,
      mpi,
      ...
    }:
      stdenv.mkDerivation ({
          inherit name version src;
          buildInputs = [mpi] ++ buildInputs;
          phases = ["unpackPhase" "patchPhase" "installPhase"];
          #-DHPL_COPY_L  force the copy of the panel L before bcast
          #-DHPL_CALL_CBLAS  call the BLAS C interface
          #-DHPL_CALL_VSIPL  call the vsip library
          #-DHPL_DETAILED_TIMING   enable detailed timers
          ## + https://www.netlib.org/benchmark/hpl/tuning.html
          preInstall = ''
            makeFlagsArray+=(arch="nix")
            cat > Make.nix
            echo ARCH="nix" >> Make.nix
            echo TOPdir=$PWD >> Make.nix
            echo 'INCdir       = $(TOPdir)/include' >> Make.nix
            echo 'BINdir       = $(TOPdir)/bin' >> Make.nix
            echo 'LIBdir       = $(TOPdir)/lib' >> Make.nix
            echo 'HPLlib       = $(LIBdir)/libhpl.a' >> Make.nix
            echo 'LAlib        = ${LAlib}' >> Make.nix
            echo 'MPlib        = -L${mpi}/lib/release ${MPlib}' >> Make.nix
            echo 'HPL_LIBS     = $(HPLlib) $(LAlib) $(MPlib)' >> Make.nix
            echo CD=cd >> Make.nix
            echo CP=cp >> Make.nix
            echo LN_S="ln -s" >> Make.nix
            echo MKDIR="mkdir -p" >> Make.nix
            echo RM="rm -f" >> Make.nix
            echo TOUCH=touch >> Make.nix
            echo 'CCNOOPT=-I$(INCdir)' >> Make.nix
            #echo 'CCFLAGS=$(CFLAGS) -I$(INCdir) -DHPL_DETAILED_TIMING -DHPL_PROGRESS_REPORT' >> Make.nix
            echo 'CCFLAGS=$(CFLAGS) -I$(INCdir) ' >> Make.nix
            echo 'LINKER       = $(CC)' >> Make.nix
            echo 'LINKFLAGS    = $(CCFLAGS) ' >> Make.nix
            echo 'ARCHIVER     = ar' >> Make.nix
            echo 'ARFLAGS      = r' >> Make.nix
            echo 'RANLIB       = echo' >> Make.nix
          '';
          postInstall = ''
            mkdir -p $out/bin
            cp bin/xhpl $out/bin
          '';
          meta = {
            description = "A Portable Implementation of the High-Performance Linpack";
          };
        }
        // extraArgs))
    args;

  hpl_cuda_ompi_volta_pascal_kepler_3_14_19 = stdenv.mkDerivation {
    name = "hpl_cuda_10.1_ompi-3.1_volta_pascal_kepler-3.14.19";
    src = fetchannex {
      url = "hpl_cuda_10.1_ompi-3.1_volta_pascal_kepler_3-14-19_ext.tgz";
      sha256 = "0xynj4yd4n7nc22pxmzxbpl64m5rlv38lwbs3j50wc94j6sjfy1x";
    };
    buildInputs = [nix-patchtools];
    libs = lib.makeLibraryPath [
      cudatoolkit_10_1.lib
      cudatoolkit_10_1.out
      nvidia_x11
      #openmpi
      mkl
      glibc
      gcc48.cc.lib
    ];
    dontStrip = true;
    installPhase = ''
      mkdir -p $out/bin
      cp xhpl* $out/bin/

      echo $libs
      autopatchelf $out
    '';
  };
in rec {
  hpl_netlib_2_3 = common {
    buildInputs = [blas];
    mpi = openmpi;
  };

  hpl_mkl_netlib_2_3 = common {
    mpi = openmpi;
    buildInputs = [mkl];
    #LAlib="-L${mkl}/lib -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -liomp5 -lm";
    LAlib = "-L${mkl}/lib -lmkl_core -lmkl_intel_lp64 -lmkl_sequential";
    CFLAGS = "-DHPL_CALL_CBLAS";
  };

  inherit hpl_cuda_ompi_volta_pascal_kepler_3_14_19;
}
