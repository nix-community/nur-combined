{ pkgs ? import <nixpkgs> { } }:

rec {
  # Custom lib, modules and other stuff
  modules = import ./modules/default.nix;

  lib = import ./lib/default.nix { inherit (pkgs) lib; };

  # Custom packages
  caia = pkgs.callPackage ./pkgs/caia { inherit caia-unwrapped; };
  caia-unwrapped = pkgs.callPackage ./pkgs/caia/unwrapped.nix { };

  digital = pkgs.callPackage ./pkgs/digital { };

  sdr = pkgs.callPackage ./pkgs/sdr.nix { };

  # build-support
  makeDevEnv = pkgs.callPackage ./pkgs/build-support/makeDevEnv { };
}
