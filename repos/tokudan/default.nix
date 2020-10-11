# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Retro tools
  cbmbasic = pkgs.callPackage ./pkgs/cbmbasic { };
  cc65 = pkgs.callPackage ./pkgs/cc65 { };
  disk-utilities = pkgs.callPackage ./pkgs/disk-utilities { };
  opencbm = pkgs.callPackage ./pkgs/opencbm { inherit cc65; };
  nibtools = pkgs.callPackage ./pkgs/nibtools { inherit cc65 opencbm; };
  superdiskindex = pkgs.callPackage ./pkgs/superdiskindex { };
  vice = pkgs.callPackage ./pkgs/vice { inherit xa; };
  xa = pkgs.callPackage ./pkgs/xa { };

  # Web apps
  freshrss = pkgs.callPackage ./pkgs/freshrss {  };
  writefreely = pkgs.callPackage ./pkgs/writefreely { };
}
