{ pkgs ? import <nixpkgs> {} }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  astrochem = pkgs.python3Packages.toPythonModule (
    pkgs.callPackage ./pkgs/astrochem {
      pythonPackages = pkgs.python3Packages;
    }
  );
}
