{ pkgs ? import <nixpkgs> { } }:
with builtins;
let
  inherit (pkgs) lib;
  nurOverlays = (import ./default.nix { }).overlays;
  overlayList = with nurOverlays; [
    lua-overrides
    python-overrides
    lua-packages
    python-packages
    fixes
    oldflash
    dochelpers
  ];
  fixList = lib.foldl' (lib.flip lib.extends) (self: pkgs) overlayList;
in lib.fix fixList
