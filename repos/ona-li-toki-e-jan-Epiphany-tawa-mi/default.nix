# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  #lib      = import ./lib { inherit pkgs; };  # Functions
  #modules  = import ./modules;                # NixOS modules
  #overlays = import ./overlays;               # nixpkgs overlays
  hmModules = import ./hm-modules;            # Home Manager modules.

  # My software.
  netcatchat       = pkgs.callPackage ./pkgs/netcatchat {};
  cobol-dvd-thingy = pkgs.callPackage ./pkgs/cobol-dvd-thingy {};
  bitmasher        = pkgs.callPackage ./pkgs/bitmasher {};
  ilo-li-sina      = pkgs.callPackage ./pkgs/ilo-li-sina {};
  cowsaypl         = pkgs.callPackage ./pkgs/cowsaypl {};
}
