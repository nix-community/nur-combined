# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  android-unpinner = pkgs.python3.pkgs.callPackage ./pkgs/android-unpinner { };
  fzf-tab-completion = pkgs.callPackage ./pkgs/fzf-tab-completion { };
  harmonoid = pkgs.callPackage ./pkgs/harmonoid { };
  jetbrains-fleet = pkgs.callPackage ./pkgs/jetbrains-fleet { };
  tulip = pkgs.callPackage ./pkgs/tulip {
    inherit tulip-api tulip-assembler tulip-enricher tulip-flagids tulip-frontend;
  };
  tulip-api = pkgs.callPackage ./pkgs/tulip-api { };
  tulip-assembler = pkgs.callPackage ./pkgs/tulip-assembler { };
  tulip-enricher = pkgs.callPackage ./pkgs/tulip-enricher { };
  tulip-flagids = pkgs.callPackage ./pkgs/tulip-flagids { };
  tulip-frontend = pkgs.callPackage ./pkgs/tulip-frontend { };
}
