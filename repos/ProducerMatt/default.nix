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

  pledge = pkgs.callPackage ./pkgs/tools/security/pledge { };
  hugs98 = pkgs.callPackage ./pkgs/development/compilers/hugs98 { };
  ripsecrets = pkgs.callPackage ./pkgs/tools/security/ripsecrets { };
  orgmk = pkgs.callPackage ./pkgs/applications/misc/orgmk { };
  yaml2nix = pkgs.callPackage ./pkgs/tools/misc/yaml2nix { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
