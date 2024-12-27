# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
#     nix-build -A tests

{ pkgs ? import <nixpkgs> { } }:

pkgs.lib.makeScope pkgs.newScope (self: with self; {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules { inherit self; }; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  tests = import ./tests { inherit self pkgs; };

  python-xextract = pkgs.callPackage ./pkgs/python-xextract { };
  linguee-api = pkgs.callPackage ./pkgs/linguee-api { inherit python-xextract; };
  linguee-api-server = pkgs.python3Packages.callPackage ./pkgs/linguee-api/server.nix { inherit linguee-api; };
})
