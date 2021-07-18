# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs) callPackage recurseIntoAttrs;
in
rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # Dev utils
  fetchDenoTarball = callPackage ./pkgs/deno-extra/fetchDenoTarball.nix { };
  bundleDeno = callPackage ./pkgs/deno-extra/bundleDeno.nix { inherit fetchDenoTarball; };

  # Defined in firefox-addons
  firefox-addons = recurseIntoAttrs (callPackage ./pkgs/firefox-addons { });

  bane = callPackage ./pkgs/bane { };
  crane = callPackage ./pkgs/crane { };
  comma = callPackage ./pkgs/comma { };
  conform = callPackage ./pkgs/conform { };
  container-diff = callPackage ./pkgs/container-diff { };
  flat-remix-theme = callPackage ./pkgs/themes/flat-remix { };
  google-fonts = callPackage ./pkgs/fonts/google-fonts { };
  grpc-web = callPackage ./pkgs/grpc-web { };
  infracost = callPackage ./pkgs/infracost { };
  ko = callPackage ./pkgs/ko { };
  konstraint = callPackage ./pkgs/konstraint { };
  nerdfont-hasklig = callPackage ./pkgs/fonts/nerdfont-hasklig { };
  rakkess = callPackage ./pkgs/rakkess { };
  scorecard = callPackage ./pkgs/scorecard { };
  subo = callPackage ./pkgs/subo { };
  tuftool = callPackage ./pkgs/tuftool { };
}
