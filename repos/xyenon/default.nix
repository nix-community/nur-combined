# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

with pkgs; rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  hmModules = import ./hm-modules; # Home Manager modules
  overlays = import ./overlays; # nixpkgs overlays

  go-check = callPackage ./pkgs/go-check { };
  lux = callPackage ./pkgs/lux { };
  catp = callPackage ./pkgs/catp { };
  github-copilot-cli = callPackage ./pkgs/github-copilot-cli { };
  libkazv = callPackage ./pkgs/libkazv { };
  kazv = libsForQt5.callPackage ./pkgs/kazv { inherit libkazv; };
  yazi = callPackage ./pkgs/yazi { inherit (darwin.apple_sdk.frameworks) Foundation; };
  yazi-unstable = callPackage ./pkgs/yazi/unstable.nix { inherit (darwin.apple_sdk.frameworks) Foundation; };
}
