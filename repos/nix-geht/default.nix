{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {inherit system;}
}: let
  overlays = import ./overlays;

  metaOverlay = self: super:
    with super.lib;
    foldl' (flip extends) (_: super) (builtins.attrValues overlays) self;

  newpkgs = pkgs.extend metaOverlay;

  mypkgs = newpkgs.callPackage ./pkgs {};
in
  rec {
    inherit overlays;
    lib = import ./lib {pkgs = newpkgs;}; # functions
    modules = import ./modules; # NixOS modules
    pkgs = mypkgs; # custom packages.
  }
  // mypkgs
