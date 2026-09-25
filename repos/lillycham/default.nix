# Lilly's NUR packages. See https://github.com/nix-community/NUR.
#
# Build a package with:
#   nix-build -A hydrus-tagger
{ pkgs ? import <nixpkgs> { } }:
{
  # Special attributes for NUR.
  lib = { };
  modules = { };
  overlays = { };

  dq = pkgs.callPackage ./pkgs/dq { };
  hydrus-tagger = pkgs.callPackage ./pkgs/hydrus-tagger { };
}
