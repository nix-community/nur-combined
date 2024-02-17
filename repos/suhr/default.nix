{ pkgs ? import <nixpkgs> {} }:

rec {
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  minimal-sddm-theme = pkgs.callPackage ./pkgs/minimal-sddm-theme { };
  _31key = pkgs.callPackage ./pkgs/31key { };
  mimi = pkgs.callPackage ./pkgs/mimi { };
  quake3-data = pkgs.callPackage ./pkgs/quake3-data { };
  augr = pkgs.callPackage ./pkgs/augr { };
  ciao = pkgs.callPackage ./pkgs/ciao { };
  iosevka-term = pkgs.callPackage ./pkgs/iosevka/term.nix { };
  frame = pkgs.callPackage ./pkgs/frame { };
  # why3 = pkgs.callPackage ./pkgs/why3 { };
  pianoteq-stage = pkgs.callPackage ./pkgs/pianoteq-stage { };
  dcpt720dwlpr = (pkgs.callPackage ./pkgs/dcpt720dw { }).driver;
  dcpt720dw-cupswrapper = (pkgs.callPackage ./pkgs/dcpt720dw { }).cupswrapper;
  sdrpp-git = pkgs.callPackage ./pkgs/sdrpp-git { };
  pharo = pkgs.callPackage ./pkgs/pharo { };
  glamoroustoolkit = pkgs.callPackage ./pkgs/glamoroustoolkit { };
}
