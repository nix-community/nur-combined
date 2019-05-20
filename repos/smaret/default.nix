{ pkgs ? import <nixpkgs> {} }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  astrochem = pkgs.pythonPackages.toPythonModule (
     pkgs.callPackage ./pkgs/astrochem {
       inherit (pkgs) pythonPackages;
       sundials = pkgs.callPackage ./pkgs/sundials2 { };
     }
  );
  casa = pkgs.callPackage ./pkgs/casa { };
  sundials2 = pkgs.callPackage ./pkgs/sundials2 { };
}
