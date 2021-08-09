{ pkgs ? import <nixpkgs> {} }:

rec {
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  minimal-sddm-theme = pkgs.callPackage ./pkgs/minimal-sddm-theme { };
  _31key = pkgs.callPackage ./pkgs/31key { };
  mimi = pkgs.callPackage ./pkgs/mimi { };
  quake3-data = pkgs.callPackage ./pkgs/quake3-data { };
  deadbeef-waveform-seekbar-plugin =
    pkgs.callPackage ./pkgs/deadbeef-waveform-seekbar-plugin { };
  augr = pkgs.callPackage ./pkgs/augr { };
  rosie = pkgs.luaPackages.callPackage ./pkgs/rosie { };
  pcem = pkgs.callPackage ./pkgs/pcem { };
  ciao = pkgs.callPackage ./pkgs/ciao { };
}
