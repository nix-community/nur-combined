{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> { inherit system; } }:

{

  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;
  hmModules = import ./hm-modules;
  ndModules = import ./nd-modules;

  dmenu = pkgs.callPackage ./pkgs/dmenu { };

  firefox-addons =
    pkgs.recurseIntoAttrs (pkgs.callPackage ./pkgs/firefox-addons { });

  hello-nur = pkgs.callPackage ./pkgs/hello-nur { };

  st = pkgs.callPackage ./pkgs/st { };

  sysfo = pkgs.callPackage ./pkgs/sysfo { };
}
