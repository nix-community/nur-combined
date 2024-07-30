{
  lib ? import <nixpkgs/lib>,
}:

lib.extend (import ./overlay.nix)
