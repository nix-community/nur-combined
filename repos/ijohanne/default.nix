{ pkgs ? import <nixpkgs> { }, sources ? import ./nix/sources.nix }:
{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;
} // (import ./pkgs { inherit pkgs sources; })
