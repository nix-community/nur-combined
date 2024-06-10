{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  drivedlgo = pkgs.callPackage ./pkgs/drivedlgo { };
}
