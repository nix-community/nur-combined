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
  modules.shiki = ./modules/shiki.nix;
  overlays = { };

  akyuu = pkgs.callPackage ./pkgs/akyuu { };
  cern-httpd = pkgs.callPackage ./pkgs/cern-httpd { };
  dq = pkgs.callPackage ./pkgs/dq { };
  engi = pkgs.callPackage ./pkgs/engi { };
  hydrus-tagger = pkgs.callPackage ./pkgs/hydrus-tagger { };
  lambdash = pkgs.callPackage ./pkgs/lambdash { };
  nibble = pkgs.callPackage ./pkgs/nibble { inherit nibble-mlx-server; };
  nibble-gui = pkgs.callPackage ./pkgs/nibble-gui { };
  shiki = pkgs.callPackage ./pkgs/shiki { };
  why = pkgs.callPackage ./pkgs/why { };
  worldwideweb = pkgs.callPackage ./pkgs/worldwideweb { };
  inherit nibble-mlx-server;
}
