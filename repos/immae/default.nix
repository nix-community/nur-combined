{ sources ? import ./nix/sources.nix, pkgs ? import sources.nixpkgs {} }:
let
  mypkgs = pkgs.callPackage ./pkgs {};
in
{
  lib = pkgs.callPackage ./lib {};
  modules = import ./modules;
  overlays = import ./overlays;
  pkgs = mypkgs;
  environments = pkgs.callPackage ./environments {};
} // mypkgs
