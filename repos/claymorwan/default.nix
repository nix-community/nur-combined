# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./modules/nixos; # NixOS modules
  homeModules = import ./modules/hm; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  deltapatcher = pkgs.callPackage ./pkgs/deltapatcher { };
  fabric-cli = pkgs.callPackage ./pkgs/fabric-cli { };
  pvpn = pkgs.callPackage ./pkgs/pvpn { };
  shimelinux = pkgs.callPackage ./pkgs/shimelinux { };
  twintaillauncher = pkgs.callPackage ./pkgs/twintaillauncher/twintaillauncher { inherit twintaillauncher-unwrapped; };
  twintaillauncher-unwrapped = pkgs.callPackage ./pkgs/twintaillauncher/twintaillauncher-unwrapped { };
  # utmt-cli = pkgs.callPackage ./pkgs/utmt-cli { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
}
