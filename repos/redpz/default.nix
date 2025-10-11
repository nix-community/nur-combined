# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  frame0 = pkgs.callPackage ./pkgs/frame0 { };
  sf-mono = pkgs.callPackage ./pkgs/sf-mono { };
  sf-pro = pkgs.callPackage ./pkgs/sf-pro { };
  printargs = pkgs.callPackage ./pkgs/printargs { };
  operator-mono-lig = pkgs.callPackage ./pkgs/operator-mono-lig { };
  symbols-nerd-font = pkgs.callPackage ./pkgs/symbols-nerd-font { };
  kanagawa-yazi = pkgs.callPackage ./pkgs/kanagawa-yazi { };
  nora = pkgs.callPackage ./pkgs/nora { };
  harmonoid = pkgs.callPackage ./pkgs/harmonoid { };
  adwaita-cross-icon-theme = pkgs.callPackage ./pkgs/adwaita-cross-icon-theme { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
