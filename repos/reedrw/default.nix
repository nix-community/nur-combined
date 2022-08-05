# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  artwiz-lemon = pkgs.callPackage ./pkgs/artwiz-lemon { };
  an-anime-game-launcher-gtk = pkgs.callPackage ./pkgs/an-anime-game-launcher-gtk { inherit an-anime-game-launcher-gtk-unwrapped; };
  an-anime-game-launcher-gtk-unwrapped = pkgs.callPackage ./pkgs/an-anime-game-launcher-gtk/unwrapped.nix { };
  bitwarden-rofi-patched = pkgs.callPackage ./pkgs/bitwarden-rofi { };
  picom-next-ibhagwan = pkgs.callPackage ./pkgs/picom-next-ibhagwan { };
  rctpm = pkgs.callPackage ./pkgs/rctpm { };
  shairport-sync-metadata-reader = pkgs.callPackage ./pkgs/shairport-sync-metadata-reader { };
  toonmux = pkgs.callPackage ./pkgs/toonmux { };
  uxplay = pkgs.callPackage ./pkgs/uxplay { };
  viddy = pkgs.callPackage ./pkgs/viddy { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
