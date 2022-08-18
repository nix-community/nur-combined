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
  ciao = pkgs.callPackage ./pkgs/ciao { };
  iosevka-term = pkgs.callPackage ./pkgs/iosevka/term.nix { };
  cbqn = pkgs.callPackage ./pkgs/cbqn { stdenv = pkgs.clangStdenv; };
  ssb-patchbay = pkgs.callPackage ./pkgs/ssb-patchbay { };
  frame = pkgs.callPackage ./pkgs/frame { };
  why3 = pkgs.callPackage ./pkgs/why3 { };
  pianoteq-stage = pkgs.callPackage ./pkgs/pianoteq-stage { };
}
