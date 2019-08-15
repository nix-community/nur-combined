{ pkgs ? import <nixpkgs> {} }:

{
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  firefox-addons = pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/firefox-addons { });
  firefox-addons-generator = pkgs.haskellPackages.callPackage ./pkgs/firefox-addons-generator { };
  home-manager = pkgs.callPackage ./pkgs/home-manager { };
}
