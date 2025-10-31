{ pkgs ? import <nixpkgs> {} }:

rec {
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  minimal-sddm-theme = pkgs.callPackage ./pkgs/minimal-sddm-theme { };
  # _31key = pkgs.callPackage ./pkgs/31key { };
  # mimi = pkgs.callPackage ./pkgs/mimi { };
  quake3-data = pkgs.callPackage ./pkgs/quake3-data { };
  augr = pkgs.callPackage ./pkgs/augr { };
  iosevka-term = pkgs.callPackage ./pkgs/iosevka/term.nix { };
  # why3 = pkgs.callPackage ./pkgs/why3 { };
  pianoteq-stage = pkgs.callPackage ./pkgs/pianoteq-stage { };
  ripplerx = pkgs.callPackage ./pkgs/ripplerx { };
  octasine = pkgs.callPackage ./pkgs/octasine { };
  surge-xt = pkgs.callPackage ./pkgs/surge-xt { };
}
