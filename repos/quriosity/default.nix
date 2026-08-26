{ pkgs ? import <nixpkgs> { } }:

{
  # Modules/Overlays
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  # Apps
  BedrockNix = pkgs.callPackage ./pkgs/apps/BedrockNix {};
  olauncher = pkgs.callPackage ./pkgs/apps/olauncher {};
  leshade = pkgs.callPackage ./pkgs/apps/leshade {};
  zen-browser = pkgs.callPackage ./pkgs/apps/zen-browser {};
  tabby = pkgs.callPackage ./pkgs/apps/tabby {};
  hyper = pkgs.callPackage ./pkgs/apps/hyper {};
  opennow = pkgs.callPackage ./pkgs/apps/opennow {};
  elio = pkgs.callPackage ./pkgs/apps/elio {};

  # SDDM themes
  echo-sddm = pkgs.callPackage ./pkgs/sddm-themes/echo-sddm {};
  where-is-my-sddm-theme = pkgs.callPackage ./pkgs/sddm-themes/where-is-my-sddm-theme {};

  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
