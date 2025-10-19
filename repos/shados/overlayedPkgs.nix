{
  nixpkgs ? import <nixpkgs> { },
}:
let
  lib = import (nixpkgs.path + "/lib") { };
  nurOverlays = (import ./default.nix { }).overlays;
  overlays = with nurOverlays; [
    nur-pkgs
    lua-overrides
    lua-packages
    python-packages
    fixes
    oldflash
    dochelpers
  ];
in
import nixpkgs.path { inherit overlays; }
