{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  comma = pkgs.callPackage ./pkgs/comma { };
  minicava = pkgs.callPackage ./pkgs/minicava { };
  rustlings = pkgs.callPackage ./pkgs/rustlings { };
  runescape-launcher = pkgs.callPackage ./pkgs/runescape-launcher { };
  swayfader = pkgs.callPackage ./pkgs/swayfader { };
  argononed = pkgs.callPackage ./pkgs/argononed { };
}
