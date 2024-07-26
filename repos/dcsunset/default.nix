# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  dc-lib = import ./lib { inherit (pkgs) lib; }; # functions
in {
  # The `lib`, `modules`, and `overlay` names are special
  lib = dc-lib;

  modules = map (m: {
    name = m;
    value = import ./modules + "/${m}";
  }) (dc-lib.listSubdirNames ./modules);

  overlays = import ./overlays; # nixpkgs overlays

  emacsPackages = builtins.listToAttrs (
    map (p: {
      name = p;
      value = pkgs.callPackage (./pkgs/emacs + "/${p}") { };
    }) (dc-lib.listSubdirNames ./pkgs/emacs)
  );

  cspellDicts = builtins.listToAttrs (
    map (p: {
      name = p;
      value = pkgs.callPackage (./pkgs/cspell-dicts + "/${p}") { };
    }) (dc-lib.listSubdirNames ./pkgs/cspell-dicts)
  );
} // (builtins.listToAttrs (
  # top-level
  map (p: {
    name = p;
    value = pkgs.callPackage (./pkgs/top-level + "/${p}") { };
  }) (dc-lib.listSubdirNames ./pkgs/top-level)
))
