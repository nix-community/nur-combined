{ pkgs, lib, ... }:
sourcesDir:
(import ../../../../lib/fetchrix-lib.nix { inherit lib; }).load {
  inherit pkgs;
  dir = sourcesDir;
}
