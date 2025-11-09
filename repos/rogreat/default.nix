# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  goverlay = pkgs.callPackage ./pkgs/goverlay { };
  gupax = pkgs.callPackage ./pkgs/gupax { };
  lenspect = pkgs.callPackage ./pkgs/lenspect { };
  pascube = pkgs.callPackage ./pkgs/pascube { };
  steam-optionx = pkgs.callPackage ./pkgs/steam-optionx { };
}
