# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:
let
  lib = import ./lib { inherit pkgs lib; }; # functions
in
{
  inherit lib pkgs;
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  nixpkgs-url-list = builtins.toJSON (lib.getMetaUrls (pkgs.lib.recurseIntoAttrs pkgs));
} // (lib.callDir ./pkgs/by-name { })
