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

  appendURL = pkgs.callPackage ./pkgs/mpvScripts/appendURL {};
  ttf-literation = pkgs.callPackage ./pkgs/fonts/ttf-literation {};
  IRust = pkgs.callPackage ./pkgs/irust {};
  pass-extension-tail = pkgs.callPackage ./pkgs/pass-extension-tail {};
  pass-sxatm = pkgs.callPackage ./pkgs/pass-sxatm {};
  junest = pkgs.callPackage ./pkgs/junest {};
  pdpmake = pkgs.callPackage ./pkgs/pdpmake {};
  chawan = pkgs.callPackage ./pkgs/chawan {};
  aercbook = pkgs.callPackage ./pkgs/aercbook {};
  pjeoffice = pkgs.callPackage ./pkgs/pjeoffice {};
}
