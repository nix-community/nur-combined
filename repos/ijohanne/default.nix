{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> { inherit system; }, sources ? import ./nix/sources.nix { inherit pkgs; } }:
{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;
} // (import ./pkgs { inherit pkgs sources; })
