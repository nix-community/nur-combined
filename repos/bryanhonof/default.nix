# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  ccache-storage-http-go = pkgs.callPackage ./pkgs/ccache-storage-http-go { };
  git-of-theseus = pkgs.callPackage ./pkgs/git-of-theseus { };
  gix-of-theseus = pkgs.callPackage ./pkgs/gix-of-theseus { };
  likec4 = pkgs.callPackage ./pkgs/likec4 { };

  # Audio plugins/tools
  ratatouille = pkgs.callPackage ./pkgs/ratatouille { };
  stomptuner = pkgs.callPackage ./pkgs/stomptuner { };
  oscmix = pkgs.callPackage ./pkgs/oscmix { };
}
