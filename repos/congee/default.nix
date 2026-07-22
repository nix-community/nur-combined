# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  # astrometry-net isn't in nixpkgs, so build it here and thread it into siril,
  # which shells out to its solve-field for local plate solving.
  astrometry-net = pkgs.callPackage ./pkgs/astrometry-net { };
in
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  some-sass-language-server = pkgs.callPackage ./pkgs/some-sass-language-server { };
  gh-image = pkgs.callPackage ./pkgs/gh-image { };
  rsql = pkgs.callPackage ./pkgs/rsql { };
  sentry = pkgs.callPackage ./pkgs/sentry { };
  engram = pkgs.callPackage ./pkgs/engram { };
  rapid-mlx = pkgs.callPackage ./pkgs/rapid-mlx { };
  llmster = pkgs.callPackage ./pkgs/llmster { };
  whatcable = pkgs.callPackage ./pkgs/whatcable { };
  inherit astrometry-net;
  siril = pkgs.callPackage ./pkgs/siril { inherit astrometry-net; };
}
