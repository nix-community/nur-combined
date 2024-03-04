# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

builtins.trace "「我书写，则为我命令。我陈述，则为我规定。」"

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  ryzen-smu = pkgs.linuxPackages.callPackage ./pkgs/linux/ryzen-smu.nix { };

  bmi260 = pkgs.linuxPackages_latest.callPackage ./pkgs/linux/bmi260.nix { };
}
