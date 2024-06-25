# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  chroot-enter = pkgs.callPackage ./pkgs/chroot-enter { };
  download-archiver = pkgs.callPackage ./pkgs/download-archiver { };
  gpg-clean-up = pkgs.callPackage ./pkgs/gpg-clean-up { };
  ls-colors = pkgs.callPackage ./pkgs/ls-colors { };
  nix-verify = pkgs.callPackage ./pkgs/nix-verify { };
  nixify = pkgs.callPackage ./pkgs/nixify { };
  rbrowser = pkgs.callPackage ./pkgs/rbrowser { };
  shrinkpdf = pkgs.callPackage ./pkgs/shrinkpdf { };
  swm = pkgs.callPackage ./pkgs/swm { };

  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
