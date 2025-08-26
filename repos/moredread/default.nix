# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  implicitcad = pkgs.haskellPackages.callPackage ./pkgs/implicitcad {};
  joplin-desktop = pkgs.callPackage ./pkgs/joplin-desktop { };
  hxcfloppyemulator = pkgs.callPackage ./pkgs/hxcfloppyemulator { };
  greaseweazel = pkgs.callPackage ./pkgs/greaseweazel { };
  mididings = pkgs.python3Packages.callPackage ./pkgs/mididings { };
}
