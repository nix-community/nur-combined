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

  steamgrid = pkgs.callPackage ./pkgs/applications/graphics/steamgrid { };
  dosbox-staging = pkgs.callPackage ./pkgs/misc/emulators/dosbox-staging { };
  #lobase = pkgs.callPackage ./pkgs/tools/misc/lobase { };
  qdl = pkgs.callPackage ./pkgs/development/mobile/qdl { };
  sbase = pkgs.callPackage ./pkgs/tools/misc/sbase { };
  ubase = pkgs.callPackage ./pkgs/tools/misc/ubase { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
