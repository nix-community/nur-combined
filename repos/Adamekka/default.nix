# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  # MARK: Packages

  gdstash = pkgs.callPackage ./pkgs/gdstash { };
  lsfg-vk-git = pkgs.callPackage ./pkgs/lsfg-vk-git { };
  lunar-tear = pkgs.callPackage ./pkgs/lunar-tear { };
  rpcs3 = pkgs.callPackage ./pkgs/rpcs3 { };
  wondershaper = pkgs.callPackage ./pkgs/wondershaper { };
}
