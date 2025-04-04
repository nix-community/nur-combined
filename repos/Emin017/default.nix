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
let
  ieda-unstable = pkgs.callPackage ./pkgs/ieda { };
in
{
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  gtkwave4 = pkgs.callPackage ./pkgs/gtkwave4 { };
  xfel = pkgs.callPackage ./pkgs/xfel { };
  lceda-pro = pkgs.callPackage ./pkgs/lceda-pro { };
  git-commit-generator = pkgs.callPackage ./pkgs/git-commit-generator { };
  ieda = ieda-unstable;
  rtl2gds = pkgs.python3Packages.callPackage ./pkgs/rtl2gds { inherit ieda-unstable; };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
