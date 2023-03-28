{ lib, config, pkgs, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in
  {

    imports = [
      /home/pim/nixos/home-manager/home-desktop-nixos.nix
    ];

    dconf.settings = {
      "org/gnome/desktop/input-sources" = {
        mru-sources = [ (mkTuple [ "xkb" "us" ]) ];
        per-window = false;
        sources = [ (mkTuple [ "xkb" "us" ]) ];
        xkb-options = [ "grp:alt_shift_toggle" "lv3:ralt_switch" "compose:ralt" "caps:none" "altwin:swap_alt_win"];
      };
    };
  }
