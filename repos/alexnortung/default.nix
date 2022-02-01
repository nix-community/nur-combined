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

  papermc-1_18_x = pkgs.callPackage ./pkgs/games/papermc/1.18.nix { };
  papermc-1_17_x = pkgs.callPackage ./pkgs/games/papermc/1.17.nix { };
  papermc-1_16_x = pkgs.callPackage ./pkgs/games/papermc/1.16.nix { };
  papermc-1_15_x = pkgs.callPackage ./pkgs/games/papermc/1.15.nix { };
  papermc-1_14_x = pkgs.callPackage ./pkgs/games/papermc/1.14.nix { };
  papermc-1_13_x = pkgs.callPackage ./pkgs/games/papermc/1.13.nix { };
  papermc-1_12_x = pkgs.callPackage ./pkgs/games/papermc/1.12.nix { };
  papermc-1_11_x = pkgs.callPackage ./pkgs/games/papermc/1.11.nix { };
  papermc-1_10_x = pkgs.callPackage ./pkgs/games/papermc/1.10.nix { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
