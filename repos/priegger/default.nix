{ pkgs ? import <nixpkgs> { }, ... }:

# special attributes
{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;
}
  # pkgs
  // (import ./pkgs { inherit pkgs; })
