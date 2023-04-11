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

  pledge = pkgs.callPackage ./pkgs/pledge { };
  cosmo = pkgs.callPackage ./pkgs/cosmo { };
  hugs98 = pkgs.callPackage ./pkgs/hugs98 { };
  ripsecrets = pkgs.callPackage ./pkgs/ripsecrets { };
  orgmk = pkgs.callPackage ./pkgs/orgmk { };
  yaml2nix = pkgs.callPackage ./pkgs/yaml2nix { };
  rsync-bpc = pkgs.callPackage ./pkgs/rsync-bpc { };
  git-fix-whitespace = pkgs.callPackage ./pkgs/git-fix-whitespace { };
  rsbkb = pkgs.callPackage ./pkgs/rsbkb { };
}
