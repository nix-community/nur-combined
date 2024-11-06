{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  astrochem = pkgs.python3Packages.toPythonModule (
    pkgs.callPackage ./pkgs/astrochem {
      pythonPackages = pkgs.python3Packages;
      sundials = pkgs.callPackage ./pkgs/astrochem/dependencies/sundials5 { };
    }
  );
  lmfit = pkgs.python3Packages.callPackage ./pkgs/python-modules/lmfit { };
  photutils =  pkgs.python3Packages.callPackage ./pkgs/python-modules/photutils { };
  pvextractor = pkgs.python3Packages.callPackage ./pkgs/python-modules/pvextractor { };
  pyradex = pkgs.python3Packages.callPackage ./pkgs/python-modules/pyradex { };
  mcfost = pkgs.callPackage ./pkgs/mcfost {
    sprng2 = pkgs.callPackage ./pkgs/mcfost/dependencies/sprng2 { };
    voro = pkgs.callPackage ./pkgs/mcfost/dependencies/voro { };
    xgboost = pkgs.callPackage ./pkgs/mcfost/dependencies/xgboost { };
  };
  pymcfost = pkgs.python3Packages.callPackage ./pkgs/python-modules/pymcfost {
    mcfost = pkgs.callPackage ./pkgs/mcfost {
        sprng2 = pkgs.callPackage ./pkgs/mcfost/dependencies/sprng2 { };
        voro = pkgs.callPackage ./pkgs/mcfost/dependencies/voro { };
        xgboost = pkgs.callPackage ./pkgs/mcfost/dependencies/xgboost { };
    };
  };
  radmc3d = pkgs.callPackage ./pkgs/radmc3d { };
  gildas = pkgs.callPackage ./pkgs/gildas { };
  imager = pkgs.callPackage ./pkgs/imager { };
}
