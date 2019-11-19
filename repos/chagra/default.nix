{ pkgs ? import <nixpkgs> {} }:

{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  ueberzug = pkgs.callPackage ./pkgs/ueberzug { };
  nudoku = pkgs.callPackage ./pkgs/nudoku { };
  ydotool = pkgs.callPackage ./pkgs/ydotool { };
  bemenu = pkgs.callPackage ./pkgs/bemenu { };
}

