{ pkgs ? import <nixpkgs> {} }:
with pkgs;
rec {
  lib = import ./lib { inherit pkgs; };
  modules = import ./modules;
  overlays = import ./overlays;

  rakudo = callPackage ./pkgs/rakudo { nqp = nqp; };
  moarvm = callPackage ./pkgs/rakudo/moarvm.nix { };
  nqp = callPackage ./pkgs/rakudo/nqp.nix { moarvm = moarvm; };
  zef = callPackage ./pkgs/rakudo/zef.nix { rakudo = rakudo; };

}

