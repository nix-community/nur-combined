# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  oneaws = pkgs.callPackage ./pkgs/oneaws { };
  ccusage = pkgs.callPackage ./pkgs/ccusage { };
  gogcli = pkgs.callPackage ./pkgs/gogcli { };
  kagiana = pkgs.callPackage ./pkgs/kagiana { };
  ccpocket-bridge = pkgs.callPackage ./pkgs/ccpocket-bridge { };
  roots = pkgs.callPackage ./pkgs/roots { };
  git-wt = pkgs.callPackage ./pkgs/git-wt { };
}
