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
}
