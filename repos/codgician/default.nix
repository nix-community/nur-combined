# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { allowUnfree = true; },
}:
{
  # The `lib`, `modules`, `overlays`, and `tests` names are special.
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  tests = import ./tests { inherit pkgs; }; # NixOS VM tests (one .nix per test)
}
// (import ./pkgs { inherit pkgs; })
