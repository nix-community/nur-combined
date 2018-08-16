# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  ### DEVELOPMENT
  lmdbxx = pkgs.callPackage ./pkgs/lmdbxx { };

  ### APPLICATIONS
  variety = pkgs.callPackage ./pkgs/variety { };
  gnubiff = pkgs.callPackage ./pkgs/gnubiff { };
  maya-calendar = pkgs.callPackage ./pkgs/maya-calendar { };

  ### GAMES
  _20kly = pkgs.callPackage ./pkgs/20kly { };
  endgame-singularity = pkgs.callPackage ./pkgs/endgame-singularity { };
  openhexagon = pkgs.callPackage ./pkgs/openhexagon { };
  powermanga = pkgs.libsForQt5.callPackage ./pkgs/powermanga { };
}

