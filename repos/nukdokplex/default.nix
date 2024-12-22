# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{ pkgs ? import <nixpkgs> { } }: {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  epson_201310w = pkgs.callPackage ./pkgs/epson_201310w { };
  afterglow-cursors-recolored-custom = pkgs.callPackage ./pkgs/afterglow-cursors-recolored-custom { };
  SonixFlasherC = pkgs.callPackage ./pkgs/SonixFlasherC { };
  gruvbox-wallpapers = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/gruvbox-wallpapers { });
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
