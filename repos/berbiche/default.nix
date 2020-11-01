{ pkgs ? import <nixpkgs> {} }:

{
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  deadd-notification-center = pkgs.callPackage ./pkgs/deadd-notification-center { };
  mpvpaper = pkgs.callPackage ./pkgs/mpvpaper { };
  waylock = pkgs.callPackage ./pkgs/waylock { };
  wlclock = pkgs.callPackage ./pkgs/wlclock { };
  wlr-sunclock = pkgs.callPackage ./pkgs/wlr-sunclock { };
}

