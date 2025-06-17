{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  # lib = import ./lib { inherit pkgs; }; # functions
  # modules = import ./modules; # NixOS modules
  # overlays = import ./overlays; # nixpkgs overlays

  # Intel compiler
  #intel-compilers-2017 = throw "2017 Intel compilers have been removed for Gricad's NUR repository. Please, use intel-compilers-2019";
  intel-oneapi = pkgs.callPackage ./pkgs/intel/oneapi.nix {
    gdk_pixbuf = pkgs.gdk-pixbuf;
  };
  intel-oneapi-hpc = pkgs.callPackage ./pkgs/intel/oneapi-hpc.nix {
    gdk_pixbuf = pkgs.gdk-pixbuf;
  };
  intel-oneapi-2022 = pkgs.callPackage ./pkgs/intel/oneapi-2022.nix {
    gdk_pixbuf = pkgs.gdk-pixbuf;
  };
  intel-oneapi-essentials = pkgs.callPackage ./pkgs/intel/oneapi-essentials.nix {
    gdk_pixbuf = pkgs.gdk-pixbuf;
  };

  amd-aocl = pkgs.callPackage ./pkgs/amd/aocl.nix { };

  lammps-impi = pkgs.callPackage ./pkgs/lammps {
    withMPI = true;
    withOneAPI = true;
    intel-oneapi = intel-oneapi;
    gcc = pkgs.gcc;
  };
}

