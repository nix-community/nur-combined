{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  digitalalovestory-bin = pkgs.callPackage ./pkgs/digitalalovestory-bin { };
}
