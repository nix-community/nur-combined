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

  comma = pkgs.callPackage ./pkgs/comma { };
  conform = pkgs.callPackage ./pkgs/conform { };
  container-diff = pkgs.callPackage ./pkgs/container-diff { };
  flat-remix-theme = pkgs.callPackage ./pkgs/themes/flat-remix { };
  go-jira = pkgs.callPackage ./pkgs/go-jira { };
  hunter = pkgs.callPackage ./pkgs/hunter { };
  infracost = pkgs.callPackage ./pkgs/infracost { };
  nerdctl = pkgs.callPackage ./pkgs/nerdctl { };
  scorecard = pkgs.callPackage ./pkgs/scorecard { };
}

