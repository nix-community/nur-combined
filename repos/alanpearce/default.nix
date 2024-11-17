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
  modules = import ./modules/nixos; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  prettier-plugin-go-template = pkgs.callPackage ./pkgs/prettier-plugin-go-template { };
  htmlformat = pkgs.callPackage ./pkgs/htmlformat { };
  emacs-unlimited-select = pkgs.callPackage ./pkgs/emacs-unlimited-select { };
  porto = pkgs.callPackage ./pkgs/porto { };
  vanity-imports = pkgs.callPackage ./pkgs/vanity-imports { };
}
