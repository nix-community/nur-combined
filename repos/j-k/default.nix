# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

let
  inherit (pkgs) callPackage;
in
{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Defined in firefox-addons
  firefox-addons = callPackage ./pkgs/firefox-addons { };

  comma = callPackage ./pkgs/comma { };
  conform = callPackage ./pkgs/conform { };
  container-diff = callPackage ./pkgs/container-diff { };
  flat-remix-theme = callPackage ./pkgs/themes/flat-remix { };
  go-jira = callPackage ./pkgs/go-jira { };
  google-fonts = callPackage ./pkgs/fonts/google-fonts { };
  hunter = callPackage ./pkgs/hunter { };
  infracost = callPackage ./pkgs/infracost { };
  ko = callPackage ./pkgs/ko { };
  konstraint = callPackage ./pkgs/konstraint { };
  nerdfont-hasklig = callPackage ./pkgs/fonts/nerdfont-hasklig { };
  scorecard = callPackage ./pkgs/scorecard { };
  subo = callPackage ./pkgs/subo { };
}

