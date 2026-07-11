# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `overlays`,
# `nixosModules`, `homeModules`, `darwinModules` and `flakeModules`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{
  pkgs ? import <nixpkgs> { },
}:

let
  yogabook-linux = pkgs.callPackage ./pkgs/yogabook-linux.nix { };
in
rec {
  # The `lib`, `overlays`, `nixosModules`, `homeModules`,
  # `darwinModules` and `flakeModules` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  nixosModules = import ./nixos-modules; # NixOS modules
  # homeModules = { }; # Home Manager modules
  # darwinModules = { }; # nix-darwin modules
  # flakeModules = { }; # flake-parts modules
  overlays = import ./overlays; # nixpkgs overlays

  jnethack = pkgs.callPackage ./pkgs/jnethack {
    inherit (lib) maintainers;
  };
  rclamonacc = pkgs.callPackage ./pkgs/rclamonacc {
    inherit (lib) maintainers;
  };
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...

  yogabook-touch-keyboard = yogabook-linux.touch-keyboard;
  yogabook-iio-sensor-proxy = yogabook-linux.iio-sensor-proxy-yogabook;
  yogabook-modes-handler = yogabook-linux.yogabook-modes-handler;
  yogabook-config = yogabook-linux.yogabook-config;
  yogabook-modules = yogabook-linux.yogabook-modules {
    inherit (pkgs.linuxPackages) kernel kernelModuleMakeFlags;
  };
}
