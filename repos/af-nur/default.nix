# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { }, bun2nix ? pkgs.callPackage ./pkgs/bun2nix-shim { }, ... }:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  homeModules = import ./hm-modules; # Home Manager modules
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  astral = pkgs.callPackage ./pkgs/astral { };
  astral-bin = pkgs.callPackage ./pkgs/astral-bin { };
  classin = pkgs.callPackage ./pkgs/classin { };
  hhsh = pkgs.callPackage ./pkgs/hhsh { };
  linuxqq-clipsync = pkgs.callPackage ./pkgs/linuxqq-clipsync { };
  mefrpc = pkgs.callPackage ./pkgs/mefrpc { };
  pixivbiu = pkgs.callPackage ./pkgs/pixivbiu { inherit bun2nix; };
  pixivbiu-bin = pkgs.callPackage ./pkgs/pixivbiu-bin { };
  xwaylandvideobridge = pkgs.kdePackages.callPackage ./pkgs/xwaylandvideobridge { };
  rikkahub-desktop = pkgs.callPackage ./pkgs/rikkahub-desktop { inherit bun2nix; };
  rikkahub-desktop-bin = pkgs.callPackage ./pkgs/rikkahub-desktop-bin { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
