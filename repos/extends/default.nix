{ pkgs ? import <nixpkgs> {} }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  pscircle = pkgs.callPackage ./pkgs/pscircle {};
  giph = pkgs.callPackage ./pkgs/giph {};
  cordless = pkgs.callPackage ./pkgs/cordless {};
  bashtop = pkgs.callPackage ./pkgs/bashtop {};
  birch = pkgs.callPackage ./pkgs/birch {};
}

