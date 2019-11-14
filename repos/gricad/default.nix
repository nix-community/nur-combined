{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  example-package = pkgs.callPackage ./pkgs/example-package { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };

  # Hello
  hello = pkgs.callPackage ./pkgs/hello { };

  # Casa
  # Versions 4.7.2 and 5.1.1 are kept for backward
  # compatibility issues.
  casa-472 = pkgs.callPackage ./pkgs/casa/4.7.2.nix { };
  casa-511 = pkgs.callPackage ./pkgs/casa/5.1.1.nix { };
  casa = pkgs.callPackage ./pkgs/casa/default.nix { };

  # Charliecloud
  charliecloud = pkgs.callPackage ./pkgs/charliecloud { };

  # Intel compiler
  #intel-compilers-2016 = pkgs.callPackage ./pkgs/intel/2016.nix { };
  #intel-compilers-2017 = pkgs.callPackage ./pkgs/intel/2017.nix { };
  #intel-compilers-2018 = pkgs.callPackage ./pkgs/intel/2018.nix { };

  # Openmpi
  #openmpi = pkgs.callPackage ./pkgs/openmpi { };
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
  psm2 = pkgs.callPackage ./pkgs/psm2 { };
  libfabric = pkgs.callPackage ./pkgs/libfabric { psm2 = psm2; };

  # Petsc
  petscComplex = pkgs.callPackage ./pkgs/petsc { scalarType = "complex"; };
  petscReal = pkgs.callPackage ./pkgs/petsc { scalarType = "real"; };
  petsc = petscComplex;

  # udocker
  udocker = pkgs.pythonPackages.callPackage ./pkgs/udocker { };

  # Arpack-ng
  arpackNG = pkgs.callPackage ./pkgs/arpack-ng { };

  # GMT
  gshhg-gmt = pkgs.callPackage ./pkgs/gmt/gshhg-gmt.nix { };
  dcw-gmt   = pkgs.callPackage ./pkgs/gmt/dcw-gmt.nix { };
  gmt = pkgs.callPackage ./pkgs/gmt { 
          gshhg-gmt = gshhg-gmt ;
          dcw-gmt = dcw-gmt ;
        };

  # ParMETIS
  #parmetis = pkgs.callPackage ./pkgs/parmetis { };

  # Trilinos
  trilinos =  pkgs.callPackage ./pkgs/trilinos { };

  # Szip
  szip =  pkgs.callPackage ./pkgs/szip { };

  # Mpi-ping example
  mpi-ping = pkgs.callPackage ./pkgs/mpi-ping { };

  # Singularity
  singularity = pkgs.callPackage ./pkgs/singularity { };

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
  fate = pkgs.callPackages ./pkgs/fate { };

  # Migrate
  migrate = pkgs.callPackages ./pkgs/migrate { };

  # GDL
  #gdl = pkgs.callPackages ./pkgs/gdl { };

  # CSA
  csa = pkgs.callPackages ./pkgs/csa { };

  # FFTW
  fftw3 = pkgs.callPackages ./pkgs/fftw { };

  # Zonation
  zonation-core = pkgs.callPackages ./pkgs/zonation-core { };

  # Scotch 6.0.5a with mumps libraries
  scotch-mumps = pkgs.callPackages ./pkgs/scotch-mumps { };

  # Obitools3
  obitools3 = pkgs.callPackage ./pkgs/obitools/obitools3.nix { };

}

