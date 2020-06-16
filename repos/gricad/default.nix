{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Hello
  hello = pkgs.callPackage ./pkgs/hello { };

  # Casa
  # Versions 4.7.2 and 5.1.1 are kept for backward
  # compatibility issues.
  #casa-472 = pkgs.callPackage ./pkgs/casa/4.7.2.nix { };
  #casa-511 = pkgs.callPackage ./pkgs/casa/5.1.1.nix { };
  #casa = pkgs.callPackage ./pkgs/casa/default.nix { };

  # Intel compiler
  #intel-compilers-2016 = pkgs.callPackage ./pkgs/intel/2016.nix { };
  intel-compilers-2017 = pkgs.callPackage ./pkgs/intel/2017.nix { };
  intel-compilers-2018 = pkgs.callPackage ./pkgs/intel/2018.nix { };
  intel-compilers-2019 = pkgs.callPackage ./pkgs/intel/2019.nix { };

  # iRods
  inherit (pkgs.callPackages ./pkgs/irods rec {
          stdenv = pkgs.llvmPackages.libcxxStdenv;
          libcxx = pkgs.llvmPackages.libcxx;
          boost = pkgs.boost160.override { inherit stdenv; };
          avro-cpp_llvm = pkgs.avro-cpp.override { inherit stdenv boost; };
        })
    irods
    irods-icommands;


  # Openmpi
  openmpi1 = pkgs.callPackage ./pkgs/openmpi { };
  openmpi2 = pkgs.callPackage ./pkgs/openmpi/2.nix { psm2 = psm2; libfabric = libfabric;};
  openmpi2-opa = pkgs.callPackage ./pkgs/openmpi/2.nix {
    psm2 = psm2;
    libfabric = libfabric;
    enableFabric = true;
  };
  openmpi2-ib = pkgs.callPackage ./pkgs/openmpi/2.nix {
    psm2 = psm2;
    libfabric = libfabric;
    enableIbverbs = true;
  };
  openmpi3 = pkgs.callPackage ./pkgs/openmpi/3.nix {
        psm2 = psm2;
  };
  openmpi4 = pkgs.callPackage ./pkgs/openmpi/4.nix {
    enablePrefix = true;
    enableFabric = true;
    libfabric = libfabric;
    psm2 = psm2;
  };
  openmpi = openmpi4;
  psm2 = pkgs.callPackage ./pkgs/psm2 { };
  libfabric = pkgs.callPackage ./pkgs/libfabric { psm2 = psm2; };

  # HPL
  hpl = pkgs.callPackage ./pkgs/hpl { mpi = openmpi4; };

  # HPL
  hp2p = pkgs.callPackage ./pkgs/hp2p { mpi = openmpi4; };

  # Petsc
  petscComplex = pkgs.callPackage ./pkgs/petsc { scalarType = "complex"; };
  petscReal = pkgs.callPackage ./pkgs/petsc { scalarType = "real"; };
  petsc = petscComplex;

  # udocker
  udocker = pkgs.pythonPackages.callPackage ./pkgs/udocker { };

  # Arpack-ng
  arpackNG = pkgs.callPackage ./pkgs/arpack-ng { };

  # Gdal
  gdal = pkgs.callPackage ./pkgs/gdal {  # forked from nixpkgs master as unstable is bugged, for dep
    libmysqlclient = pkgs.mysql // {lib = {dev = pkgs.mysql;};};
  };

  # GMT
  gshhg-gmt = pkgs.callPackage ./pkgs/gmt/gshhg-gmt.nix { };
  dcw-gmt   = pkgs.callPackage ./pkgs/gmt/dcw-gmt.nix { };
  gmt = pkgs.callPackage ./pkgs/gmt {
          gdal = gdal ;
          gshhg-gmt = gshhg-gmt ;
          dcw-gmt = dcw-gmt ;
        };

  # Trilinos
  trilinos =  pkgs.callPackage ./pkgs/trilinos { 
    suitesparse = suitesparse;
    openmpi = openmpi4;
  };

  # Szip
  szip =  pkgs.callPackage ./pkgs/szip { };

  # Mpi-ping example
  mpi-ping = pkgs.callPackage ./pkgs/mpi-ping { };

  # Singularity
  singularity = pkgs.callPackage ./pkgs/singularity { 
    buildGoModule = pkgs.buildGo113Module;
    go = pkgs.go_1_13;
  };

  # PLPlot
  plplot = pkgs.callPackage ./pkgs/plplot { };

  # Hoppet
  hoppet = pkgs.callPackage ./pkgs/hoppet { };

  # applgrid
  applgrid = pkgs.callPackage ./pkgs/applgrid { };

  # LHApdf 5.9
  lhapdf59 = pkgs.callPackage ./pkgs/lhapdf59 { };

  # Bagel
  bagel = pkgs.callPackage ./pkgs/bagel { };

  # stacks
  stacks = pkgs.callPackages ./pkgs/stacks { };

  # messer-slim
  messer-slim = pkgs.callPackages ./pkgs/messer-slim { };

  # Fate
  fate = pkgs.callPackages ./pkgs/fate { gdal = gdal; };

  # Migrate
  migrate = pkgs.callPackages ./pkgs/migrate { };

  # GDL
  gdl = pkgs.callPackages ./pkgs/gdl {
    plplot = plplot;
    fftw3 = fftw3;
  };

  # CSA
  #csa = pkgs.callPackages ./pkgs/csa { };

  # FFTW
  fftw3 = pkgs.callPackages ./pkgs/fftw { };

  # Zonation
  zonation-core = pkgs.callPackages ./pkgs/zonation-core { gdal = gdal ; };

  # Scotch 6.0.5a with mumps libraries
  scotch-mumps = pkgs.callPackages ./pkgs/scotch-mumps { };

  # Obitools3
  obitools3 = pkgs.callPackage ./pkgs/obitools/obitools3.nix { };

  # Suitesparse
  suitesparse = pkgs.callPackage ./pkgs/suitesparse  { };

  # GTS snapshot-121130 (snapshot version dep for Gerris)
  gts121130 = pkgs.callPackage ./pkgs/gts  { };

  # Gerris
  gerris = pkgs.callPackage ./pkgs/gerris { 
    fftw3  = fftw3;
    gts = gts121130;
  };

}

