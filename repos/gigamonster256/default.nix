# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{pkgs ? import <nixpkgs> {}}: let
  otcl = pkgs.callPackage ./pkgs/otcl.nix {};
in let
  tclcl = pkgs.callPackage ./pkgs/tclcl.nix {inherit otcl;};
in {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  inherit otcl tclcl;
  ns-2 = pkgs.callPackage ./pkgs/ns2 {inherit otcl tclcl;};
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
