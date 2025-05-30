{ pkgs, ... }:
let
  sway-disable-titlebar-unwrapped = pkgs.sway-unwrapped.overrideAttrs (
    _final: _prev: {
      patches = [
        (pkgs.fetchpatch {
          url = "https://codeberg.org/neuromagus/disable_titlebar_in_sway/raw/branch/main/disable_titlebar_sway1-10.patch";
          hash = "sha256-okX63A9bBPnfYFZTtcQPhyKHUCzaEqtDwT/FNFy0xOM=";
        })
      ];
    }
  );
in
pkgs.sway.override { sway-unwrapped = sway-disable-titlebar-unwrapped; }
