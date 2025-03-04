# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  datasette-leaflet = lib.callPackage "datasette-leaflet" { };
  datasette-cluster-map = lib.callPackage "datasette-cluster-map" { inherit datasette-leaflet; };

  beets-yearfixer = lib.callPackage "beets-yearfixer" { };
  beets-originquery = lib.callPackage "beets-originquery" { };
  beets-summarize = lib.callPackage "beets-summarize" { };
  beets-filetote = lib.callPackage "beets-filetote" { };

  autobean = lib.callPackage "autobean" { };
  autobean-refactor = lib.callPackage "autobean-refactor" { };
  fava-dashboards = lib.callPackage "fava-dashboards" { };

  stash = lib.callPackage "stash" { };
}
