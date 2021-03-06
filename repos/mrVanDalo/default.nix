# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # video/photo
  fuji-cam-wifi-tool = pkgs.callPackage ./pkgs/fuji-cam-wifi-tool { };
  pixelnuke = pkgs.callPackage ./pkgs/pixelnuke { };

  # audio
  wolf-spectrum = pkgs.callPackage ./pkgs/wolf-spectrum { };
  lv2vst = pkgs.callPackage ./pkgs/lv2vst { };
  bitwig-studio-3_1_2 =
    pkgs.callPackage ./pkgs/bitwig/bitwig-studio-3.1.2.nix { };
  bitwig-studio-3_1_3 =
    pkgs.callPackage ./pkgs/bitwig/bitwig-studio-3.1.3.nix { };

  # terminal
  navi = pkgs.callPackage ./pkgs/navi { };
  navi-master = pkgs.callPackage ./pkgs/navi/master.nix { };
}

