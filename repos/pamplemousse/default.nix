# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib;
  modules = import ./modules;
  overlays = import ./overlays;

  python3Packages = {
    cooldict = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/cooldict {};
    crypto-commons = pkgs.python3.pkgs.callPackage ./pkgs/python-modules/crypto-commons {};
  };
}
