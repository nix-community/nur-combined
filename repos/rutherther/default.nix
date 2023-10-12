# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <unstable> {} }: {
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  firefoxpwa = pkgs.callPackage ./pkgs/firefoxpwa { };
  firefoxpwa-unwrapped = pkgs.callPackage ./pkgs/firefoxpwa/unwrapped.nix { };

  rutherther-sequence-detector = pkgs.callPackage ./pkgs/rutherther/sequence-detector.nix { };
  rutherther-mpris-ctl = pkgs.callPackage ./pkgs/rutherther/mpris-ctl.nix { };
}
