{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  astrochem = pkgs.python3Packages.toPythonModule (
    pkgs.callPackage ./pkgs/astrochem {
      pythonPackages = pkgs.python3Packages;
      sundials = pkgs.callPackage ./pkgs/astrochem/dependencies/sundials5 { };
    }
  );
  lmfit = pkgs.python3Packages.callPackage ./pkgs/python-modules/lmfit { };
  # FIXME: This fails to build because aplpy in broken in nixpkgs
  #pvextractor = pkgs.python3Packages.callPackage ./pkgs/python-modules/pvextractor { };
  # FIXME: This fails to build because astroquery is broken in nixpkgs
  #pyradex = pkgs.python3Packages.callPackage ./pkgs/python-modules/pyradex { };
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
}
