# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:
let 
  inherit (pkgs) pkgsCross;

in

  {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  plater = pkgs.callPackage ./pkgs/plater { };
  rfm = pkgs.callPackage ./pkgs/rfm { };
  libmesh = pkgs.callPackages ./pkgs/mesh { };
  /*
  klipper = pkgs.callPackages ./pkgs/klipper {
    avrgcc = pkgsCross.avr.buildPackages.gcc;
    #avrlibc = pkgsCross.avr.buildPackages.libcCross;
    avrbinutils = pkgsCross.avr.buildPackages.binutils;
    gcc-armhf-embedded = pkgsCross.armhf-embedded.buildPackages.gcc;
  };
  */

}

