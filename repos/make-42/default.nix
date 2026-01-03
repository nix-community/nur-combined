# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  creality-print-cli = pkgs.callPackage ./pkgs/creality-print-cli {};
  hayai = pkgs.callPackage ./pkgs/hayai {};
  himitsu = pkgs.callPackage ./pkgs/himitsu {};
  kuiper = pkgs.callPackage ./pkgs/kuiper {};
  nezumi-p = pkgs.callPackage ./pkgs/nezumi-p {};
  xyosc = pkgs.callPackage ./pkgs/xyosc {};

  ntsc-rs = pkgs.callPackage ./pkgs/ntsc-rs {};
  assetripper = pkgs.callPackage ./pkgs/assetripper {};

  akai-ito = pkgs.callPackage ./pkgs/akai-ito {};

  meshroom = pkgs.callPackage ./pkgs/meshroom {};

  denise = pkgs.callPackage ./pkgs/denise {};

  ladybird = pkgs.callPackage ./pkgs/ladybird {};

  sdrtrunk = pkgs.callPackage ./pkgs/sdrtrunk {};
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
