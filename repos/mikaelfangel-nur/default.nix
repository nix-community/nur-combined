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

  battery-wallpaper = pkgs.callPackage ./pkgs/ba/battery-wallpaper { };
  clx = pkgs.callPackage ./pkgs/cl/clx { };
  gitpolite = pkgs.callPackage ./pkgs/gi/gitpolite { };
  quiet = pkgs.callPackage ./pkgs/qu/quiet { };
  rmosxf = pkgs.callPackage ./pkgs/rm/rmosxf { };
  spacedrive = pkgs.callPackage ./pkgs/sp/spacedrive { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
