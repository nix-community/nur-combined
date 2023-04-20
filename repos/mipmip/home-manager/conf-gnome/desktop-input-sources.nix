{ lib, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  dconf.settings = {

    # TODO CHECK OVERRIDE STRATEGY ON LEGO1
    "org/gnome/desktop/input-sources" = {
      mru-sources = [ (mkTuple [ "xkb" "us" ]) ];
      per-window = false;
      sources = [ (mkTuple [ "xkb" "us" ]) ];
      xkb-options = [ "grp:alt_shift_toggle" "lv3:ralt_switch" "compose:ralt" "caps:none"];
    };

  };
}
