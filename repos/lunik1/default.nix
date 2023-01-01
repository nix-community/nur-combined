{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  amazing-marvin = pkgs.callPackage ./pkgs/amazing-marvin { };
}
