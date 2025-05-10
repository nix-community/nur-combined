# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # example-package = pkgs.callPackage ./pkgs/example-package { };
  applet-darwinmenu = pkgs.callPackage ./pkgs/applet-darwinmenu {};
  applet-kara = pkgs.callPackage ./pkgs/applet-kara {};
  gabarito = pkgs.callPackage ./pkgs/gabarito {};
  mplus = pkgs.callPackage ./pkgs/mplus {};
  sgdboop = pkgs.callPackage ./pkgs/sgdboop {};
  urbanist = pkgs.callPackage ./pkgs/urbanist {};
}
