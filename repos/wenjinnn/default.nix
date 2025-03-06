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

  # example-package = pkgs.callPackage ./pkgs/example-package { };
  wechat-universal = pkgs.callPackage ./pkgs/wechat-universal {};
  wechat-license = pkgs.callPackage ./pkgs/wechat-license {};

  hiddify-next = pkgs.callPackage ./pkgs/hiddify-next { };
  rofi-network-manager = pkgs.callPackage ./pkgs/rofi-network-manager { };
  rofi-screenshot-wayland = pkgs.callPackage ./pkgs/rofi-screenshot-wayland { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
