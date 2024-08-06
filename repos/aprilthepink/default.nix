# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  suyu-mainline = import ./pkgs/suyu {
    branch = "mainline";
    inherit (pkgs) libsForQt5 fetchFromGitea;
  };

  #example-package = pkgs.callPackage ./pkgs/example-package { };
  godot4_2 = pkgs.callPackage ./pkgs/godot_4_2 { };
  stellwerksim-launcher = pkgs.callPackage ./pkgs/stellwerksim-launcher { };
  tennable-client-own = pkgs.callPackage ./pkgs/tennable-client-own { };
  
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
