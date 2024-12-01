# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }: {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  dup-img-finder = pkgs.callPackage ./pkgs/dup-img-finder { };
  idbuilder = pkgs.callPackage ./pkgs/idbuilder { };
  microsoft-todo-electron = pkgs.callPackage ./pkgs/microsoft-todo-electron { };
  sh-history-filter = pkgs.callPackage ./pkgs/sh-history-filter { };

  mojave-dyn = pkgs.callPackage ./pkgs/mojave-dyn { };
  catalina-dyn = pkgs.callPackage ./pkgs/catalina-dyn { };
  bigsur-dyn = pkgs.callPackage ./pkgs/bigsur-dyn { };
}
