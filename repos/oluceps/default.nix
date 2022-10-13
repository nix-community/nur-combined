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

  Graphite-cursors = pkgs.callPackage ./pkgs/Graphite-cursors { };
  rustplayer = pkgs.callPackage ./pkgs/RustPlayer { };
  sing-box = pkgs.callPackage ./pkgs/sing-box { };
  oppo-sans = pkgs.callPackage ./pkgs/oppo-sans { };
  san-francisco = pkgs.callPackage ./pkgs/san-francisco { };
  v2ray-plugin = pkgs.callPackage ./pkgs/v2ray-plugin { };
  plangothic = pkgs.callPackage ./pkgs/plangothic { };
  maple-font = pkgs.callPackage ./pkgs/maple-font { }; #surrealdb = pkgs.callPackage ./pkgs/surrealdb { };  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  maoken-tangyuan = pkgs.callPackage ./pkgs/maoken-tangyuan { };
  # ...
}
