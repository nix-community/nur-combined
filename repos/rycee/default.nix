{ pkgs ? import <nixpkgs> {} }:

{
  lib = import ./lib { inherit (pkgs) lib; };
  modules = import ./modules;      # NixOS modules.
  overlays = import ./overlays;    # Nixpkgs overlays.
  hmModules = import ./hm-modules; # Home Manager modules.
  ndModules = import ./nd-modules; # nix-darwin modules.

  firefox-addons = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/firefox-addons { });
  firefox-addons-generator = pkgs.haskellPackages.callPackage ./pkgs/firefox-addons-generator { };
}
