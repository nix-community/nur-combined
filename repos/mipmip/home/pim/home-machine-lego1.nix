{ lib, config, pkgs, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in
  {
    imports = [
      ./home-base-nixos-desktop.nix
      ./files-secondbrain
      ./files-i-am-desktop
    ];

    dconf.settings = {
      "org/gnome/desktop/input-sources" = {
        #mru-sources = [ (mkTuple [ "xkb" "us" ]) ];
        per-window = false;
        sources = [ (mkTuple [ "xkb" "us" ]) ];
        xkb-options = [

#          "altwin:swap_alt_win"

          "grp:alt_shift_toggle"
          "lv3:ralt_switch"
          "compose:ralt"
          "caps:none"];
      };
    };
  }
