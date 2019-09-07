# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  neovim-gtk = with pkgs.lib; let
    min-cargo-vendor = "0.1.23";
    packageOlder = p: v: versionOlder (getVersion p) v;
    cargoVendorTooOld = cargo-vendor: packageOlder cargo-vendor min-cargo-vendor;
  in pkgs.callPackage ./pkgs/neovim-gtk { oldCargoVendor = cargoVendorTooOld pkgs.cargo-vendor; };
  avr8-burn-omat = pkgs.callPackage ./pkgs/avr8-burn-omat { };
  simulavr = pkgs.callPackage ./pkgs/simulavr { };
  # example-package = pkgs.callPackage ./pkgs/example-package { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}

