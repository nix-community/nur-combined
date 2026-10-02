# Lilly's NUR packages. See https://github.com/nix-community/NUR.
#
# Build a package with:
#   nix-build -A hydrus-tagger
{ pkgs ? import <nixpkgs> { } }:
let
  nibble-mlx-server = pkgs.callPackage ./pkgs/nibble-mlx-server { };
in
{
  # Special attributes for NUR.
  lib = { };
  modules = { };
  overlays = { };

  dq = pkgs.callPackage ./pkgs/dq { };
  hydrus-tagger = pkgs.callPackage ./pkgs/hydrus-tagger { };
  nibble = pkgs.callPackage ./pkgs/nibble { inherit nibble-mlx-server; };
  nibble-gui = pkgs.callPackage ./pkgs/nibble-gui { };
  inherit nibble-mlx-server;
}
