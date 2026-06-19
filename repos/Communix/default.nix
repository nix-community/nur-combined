# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

{

  bibox = pkgs.callPackage ./pkgs/bibox { };
  # foldit = pkgs.callPackage ./pkgs/foldit { };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
  noctalia = pkgs.callPackage ./pkgs/noctalia { };
  psysonic = pkgs.callPackage ./pkgs/psysonic { };
}
