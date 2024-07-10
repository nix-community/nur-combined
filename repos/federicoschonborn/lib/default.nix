{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}:

pkgs.lib.extend (import ./overlay.nix)
