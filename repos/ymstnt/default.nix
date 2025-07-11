# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  beeper = pkgs.callPackage ./pkgs/beeper { };
  deepdwn = pkgs.callPackage ./pkgs/deepdwn { };
  lifeograph = pkgs.callPackage ./pkgs/lifeograph { };
  lunatask = pkgs.callPackage ./pkgs/lunatask { };
  minecraft-console-client = pkgs.callPackage ./pkgs/minecraft-console-client { };
  surf = pkgs.callPackage ./pkgs/surf { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
