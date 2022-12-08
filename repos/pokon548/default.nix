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

  todoist-electron = pkgs.callPackage ./pkgs/todoist-electron { };
  v2raya-unstable = pkgs.callPackage ./pkgs/v2raya-bin { };
  tencent-qq-electron = pkgs.callPackage ./pkgs/tencent-qq-electron { };
  tencent-qq-electron-bwrap = pkgs.callPackage ./pkgs/tencent-qq-electron-bwrap { };

  plasma5-wallpapers-dynamic = pkgs.libsForQt5.callPackage ./pkgs/plasma5-wallpapers-dynamic { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
