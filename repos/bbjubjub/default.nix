# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  semiphemeral = pkgs.python3Packages.callPackage pkgs/semiphemeral {};

  mars-simulator = pkgs.callPackage pkgs/mars-simulator {};

  ocrodjvu = pkgs.callPackage pkgs/ocrodjvu {};

  teck-programmer = pkgs.teck-programmer;  # alias added 2021-07-19

  chromium-extensions = pkgs.callPackage pkgs/chromium-extensions {};

  yaru-mixed-theme = yaru-classic-theme;  # alias added 2021-10-02

  yaru-classic-theme = pkgs.callPackage pkgs/yaru-classic { };

  garlicshare = pkgs.callPackage pkgs/garlicshare { };
}
