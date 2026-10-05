# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  # Builds a package's `passthru.updateScript` from `pkgs/<name>/update.py`.
  mkUpdateScript = pkgs.callPackage ./lib/mk-update-script.nix { };
in
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  computer-use-linux = pkgs.callPackage ./pkgs/computer-use-linux { inherit mkUpdateScript; };
  dsh = pkgs.callPackage ./pkgs/dsh { inherit mkUpdateScript; };
  cua-driver = pkgs.callPackage ./pkgs/cua-driver { inherit mkUpdateScript; };
  rime-data-flypy = pkgs.callPackage ./pkgs/rime-data-flypy { };
}
