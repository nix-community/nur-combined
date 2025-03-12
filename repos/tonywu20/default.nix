{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Hello
  hello = pkgs.callPackage ./pkgs/hello { };

  # Intel compiler
  #intel-compilers-2017 = throw "2017 Intel compilers have been removed for Gricad's NUR repository. Please, use intel-compilers-2019";
  intel-compilers-2018 = pkgs.callPackage ./pkgs/intel/2018.nix { };
  intel-compilers-2019 = pkgs.callPackage ./pkgs/intel/2019.nix { };
  intel-oneapi = pkgs.callPackage ./pkgs/intel/oneapi.nix { 
    gdk_pixbuf = pkgs.gdk-pixbuf; 
  };
  intel-oneapi-2022 = pkgs.callPackage ./pkgs/intel/oneapi-2022.nix { 
    gdk_pixbuf = pkgs.gdk-pixbuf; 
  };

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
        libfabric = libfabric;
  };
  openmpi4 = pkgs.callPackage ./pkgs/openmpi/4.nix {
    enablePrefix = true;
    fabricSupport = true;
    libfabric = libfabric;
    ucx = ucx;
  };
  openmpi5 = pkgs.callPackage ./pkgs/openmpi/5.nix {
    enablePrefix = true;
    fabricSupport = true;
    libfabric = libfabric;
    ucx = ucx;
  };

  openmpi = openmpi5;

  psm2 = pkgs.callPackage ./pkgs/psm2 { };
  libfabric = pkgs.callPackage ./pkgs/libfabric { };
  # Now obsolete, by libfabric 1.17 which enables OPX
      libfabric-cornelis = pkgs.callPackage ./pkgs/libfabric-cornelis { enablePsm2 = true; };
  openmpi-intel =  pkgs.callPackage ./pkgs/openmpi/intel.nix {
    withOneAPI = true;
    intel-oneapi = intel-oneapi;
    gcc = pkgs.gcc;
  };

  ucx = pkgs.callPackage ./pkgs/ucx { enableRocm = true; };

  # HPL
  hpl = pkgs.callPackage ./pkgs/hpl { mpi = openmpi4; };

  # Trilinos
  # Now is upstream
  #trilinos =  pkgs.callPackage ./pkgs/trilinos { 
  #  openmpi = openmpi4;
  #};

  # Fate
  fate = pkgs.callPackage ./pkgs/fate { };

  # GDL
  gdl = pkgs.callPackage ./pkgs/gdl { };

  # Zonation
  # Requires qt4 which is not maintained anymore
  #zonation-core = pkgs.callPackage ./pkgs/zonation-core { };

  # Scotch with mumps libraries
  scotch-mumps = pkgs.callPackage ./pkgs/scotch-mumps { };

  # Obitools3
  obitools3 = pkgs.callPackage ./pkgs/obitools/obitools3.nix { };

  # GTS snapshot-121130 (snapshot version dep for Gerris)
  gts121130 = pkgs.callPackage ./pkgs/gts  { };          

  # Gerris
  gerris = pkgs.callPackage ./pkgs/gerris { gts = gts121130; };

  # Iqtree
  iqtree = pkgs.callPackage ./pkgs/iqtree  { };

  # Beagle
  beagle = pkgs.callPackage ./pkgs/beagle  { };

  # Siesta
  siesta =  pkgs.callPackage ./pkgs/siesta { 
    useMpi = true;
    mpi = pkgs.mpich;
  };

  lammps-impi =  pkgs.callPackage ./pkgs/lammps {
    withMPI = true;
    withOneAPI = true;
    intel-oneapi = intel-oneapi;
    gcc = pkgs.gcc;
  };

  # osu micro benchmarks
  osu-micro-benchmarks =  pkgs.callPackage ./pkgs/osu-micro-benchmarks { 
    #mpi = openmpi3;
    #mpi = pkgs.mpich;
    mpi = openmpi5;
  };

  hp2p = pkgs.callPackage ./pkgs/hp2p { mpi = openmpi; };
  hp2p-intel = pkgs.callPackage ./pkgs/hp2p/intel.nix {
     intel-oneapi = intel-oneapi; 
     gcc = pkgs.gcc; 
  };
  
  hpdbscan = pkgs.callPackage ./pkgs/hpdbscan  { };

  kokkos =  pkgs.callPackage ./pkgs/kokkos {
    withOneAPI = true;
    intel-oneapi = intel-oneapi;
    gcc = pkgs.gcc11;
  };

  fineRADstructure = pkgs.callPackage ./pkgs/fineRADstructure { };

}

