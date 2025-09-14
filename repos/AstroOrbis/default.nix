# Defaulting to <nixpkgs> lets us use nix-build -A pkgname, but we need to take it as argument
{ pkgs ? import <nixpkgs> { }, }:
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # And now, the packages
  agave-cli = pkgs.callPackage ./pkgs/agave-cli { };
  mtgatool-desktop = pkgs.callPackage ./pkgs/mtgatool-desktop { };
}
