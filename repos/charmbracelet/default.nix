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

  charm = pkgs.callPackage ./pkgs/charm { };
  confettysh = pkgs.callPackage ./pkgs/confettysh { };
  freeze = pkgs.callPackage ./pkgs/freeze { };
  glow = pkgs.callPackage ./pkgs/glow { };
  gum = pkgs.callPackage ./pkgs/gum { };
  melt = pkgs.callPackage ./pkgs/melt { };
  mods = pkgs.callPackage ./pkgs/mods { };
  pop = pkgs.callPackage ./pkgs/pop { };
  skate = pkgs.callPackage ./pkgs/skate { };
  soft-serve = pkgs.callPackage ./pkgs/soft-serve { };
  vhs = pkgs.callPackage ./pkgs/vhs { };
  wishlist = pkgs.callPackage ./pkgs/wishlist { };
}
