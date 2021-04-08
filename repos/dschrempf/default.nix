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

  # Evolution.
  beast = pkgs.callPackage ./pkgs/evolution/beast { };
  beast2 = pkgs.callPackage ./pkgs/evolution/beast2 { };
  figtree = pkgs.callPackage ./pkgs/evolution/figtree { };
  iqtree2 = pkgs.callPackage ./pkgs/evolution/iqtree2 { };
  tracer = pkgs.callPackage ./pkgs/evolution/tracer { };

  # Misc.
  biblib = pkgs.callPackage ./pkgs/misc/biblib { };
  vimiv-qt = pkgs.callPackage ./pkgs/misc/vimiv-qt { };
}
