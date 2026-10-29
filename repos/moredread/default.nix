# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  implicitcad = pkgs.haskellPackages.callPackage ./pkgs/implicitcad { };
  # Removed from this repo; nixpkgs carries them now
  joplin-desktop = pkgs.lib.warn "nur.repos.moredread.joplin-desktop is no longer maintained here, use joplin-desktop from nixpkgs" pkgs.joplin-desktop;
  greaseweazel = pkgs.lib.warn "nur.repos.moredread.greaseweazel is no longer maintained here, use greaseweazle from nixpkgs" pkgs.greaseweazle;

  hxcfloppyemulator = pkgs.callPackage ./pkgs/hxcfloppyemulator { };
  mididings = pkgs.python3Packages.callPackage ./pkgs/mididings { };
}
