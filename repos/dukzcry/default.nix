# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

let
  nur = import ./default.nix {};
in {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules { inherit nur; }; # NixOS modules
  overlays = import ./overlays { inherit nur; }; # nixpkgs overlays

  example-package = pkgs.callPackage ./pkgs/example-package { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
  k380-function-keys-conf = pkgs.callPackage ./pkgs/k380-function-keys-conf { };
  knobkraft-orm = pkgs.callPackage ./pkgs/knobkraft-orm { };
  realrtcw = pkgs.callPackage ./pkgs/realrtcw { };
}

