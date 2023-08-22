# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  example-package = pkgs.callPackage ./pkgs/example-package { };
  hello-nur = pkgs.callPackage ./pkgs/hello-nur { };
  rusty-rain = pkgs.callPackage ./pkgs/rusty-rain { };
  shinydir = pkgs.callPackage ./pkgs/shinydir { };
  lsd-git = pkgs.callPackage ./pkgs/lsd-git { };
  specsheet = pkgs.callPackage ./pkgs/specsheet { };
  ind = pkgs.callPackage ./pkgs/ind { };
  cbtr = pkgs.callPackage ./pkgs/cbtr { };
  git-track-repos = pkgs.callPackage ./pkgs/git-track-repos { };
  new-stow = pkgs.callPackage ./pkgs/new-stow { };
  shim = pkgs.callPackage ./pkgs/shim { };
  ide = pkgs.callPackage ./pkgs/ide { };
}
