# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  cangjieBuildPkgs ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/50ab793786d9de88ee30ec4e4c24fb4236fc2674.tar.gz";
    sha256 = "sha256-/bVBlRpECLVzjV19t5KMdMFWSwKLtb5RyXdjz3LJT+g=";
  }) { system = pkgs.stdenv.hostPlatform.system; },
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
  cangjie = pkgs.callPackage ./pkgs/cangjie { inherit cangjieBuildPkgs; };
  cangjie-bin = pkgs.callPackage ./pkgs/cangjie/binary.nix { };
  code996 = pkgs.callPackage ./pkgs/code996 { };
  dnspick = pkgs.callPackage ./pkgs/dnspick { };
  ghost-downloader-3 = pkgs.callPackage ./pkgs/ghost-downloader-3 { };
  ipgw = pkgs.callPackage ./pkgs/ipgw { };
  meatshell = pkgs.callPackage ./pkgs/meatshell { };
  meatshell-x86_64-bin = pkgs.callPackage ./pkgs/meatshell/x86_64-bin.nix { };
  nyaterm = pkgs.callPackage ./pkgs/nyaterm { };
  nyaterm-x86_64-bin = pkgs.callPackage ./pkgs/nyaterm/x86_64-bin.nix { };
  quien = pkgs.callPackage ./pkgs/quien { };
  seekey = pkgs.callPackage ./pkgs/seekey { };
  uipro-cli = pkgs.callPackage ./pkgs/uipro-cli { };
}
