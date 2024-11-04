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

  zju-connect = pkgs.callPackage ./pkgs/zju-connect { };
  wpsoffice = pkgs.libsForQt5.callPackage ./pkgs/wpsoffice { };
  wechat-universal-bwrap = pkgs.callPackage ./pkgs/wechat-universal-bwrap { };
  wemeet-bin-bwrap = pkgs.callPackage ./pkgs/wemeet-bin-bwrap { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
  # ...
}
