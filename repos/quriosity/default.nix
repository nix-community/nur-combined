{ pkgs ? import <nixpkgs> { } }:

{
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  BedrockNix = pkgs.callPackage ./pkgs/BedrockNix {};
  olauncher = pkgs.callPackage ./pkgs/olauncher {};
  echo-sddm = pkgs.callPackage ./pkgs/echo-sddm {};
  leshade = pkgs.callPackage ./pkgs/leshade {};
  zen-browser = pkgs.callPackage ./pkgs/zen-browser {};
  tabby = pkgs.callPackage ./pkgs/tabby {};
  hyper = pkgs.callPackage ./pkgs/hyper {};
  where-is-my-sddm-theme = pkgs.callPackage ./pkgs/where-is-my-sddm-theme {};

  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...
}
