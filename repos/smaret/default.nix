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
  radmc3d = pkgs.callPackage ./pkgs/radmc3d { };
  gildas = pkgs.callPackage ./pkgs/gildas { };
  imager = pkgs.callPackage ./pkgs/imager { };
}
