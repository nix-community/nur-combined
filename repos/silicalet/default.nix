# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

{
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  amber-lsp = pkgs.callPackage ./pkgs/amber-lsp { };
  cangjie = pkgs.callPackage ./pkgs/cangjie { };
  code996 = pkgs.callPackage ./pkgs/code996 { };
  dnspick = pkgs.callPackage ./pkgs/dnspick { };
  ghost-downloader-3 = pkgs.callPackage ./pkgs/ghost-downloader-3 { };
  ipgw = pkgs.callPackage ./pkgs/ipgw { };
  meatshell = pkgs.callPackage ./pkgs/meatshell { };
  quien = pkgs.callPackage ./pkgs/quien { };
  uipro-cli = pkgs.callPackage ./pkgs/uipro-cli { };
}
