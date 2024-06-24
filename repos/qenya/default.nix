{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  digitalalovestory = pkgs.pkgsi686Linux.callPackage ./pkgs/digitalalovestory { };
  digitalalovestory-bin = pkgs.pkgsi686Linux.callPackage ./pkgs/digitalalovestory-bin { };
}
