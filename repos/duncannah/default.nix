{
  pkgs ? import <nixpkgs> { },
}:

{
  lib = import ./lib { inherit pkgs; };
  nixosModules = import ./nixos-modules;
  overlays = import ./overlays;

  gomerge = pkgs.callPackage ./pkgs/gomerge { };
}
