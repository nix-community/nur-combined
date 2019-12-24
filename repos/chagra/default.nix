{ pkgs ? import <nixpkgs> {} }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  ueberzug = pkgs.callPackage ./pkgs/ueberzug { };
  nudoku = pkgs.callPackage ./pkgs/nudoku { };
  swayblocks = pkgs.callPackage ./pkgs/swayblocks { };
  cboard = pkgs.callPackage ./pkgs/cboard { };
  ripcord = pkgs.callPackage ./pkgs/ripcord { };
  ydotool = pkgs.callPackage ./pkgs/ydotool { };
}

