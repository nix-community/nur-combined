{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
  lib ? pkgs.lib,
}:

lib.extend (import ./overlay.nix)
