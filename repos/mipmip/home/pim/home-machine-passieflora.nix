{ lib, config, pkgs, ... }:

let
  mkTuple = lib.hm.gvariant.mkTuple;
in
{
  imports = [
    ./_hm-modules
    ./_roles/home-base-all.nix
    ./_roles/home-base-nixos-desktop.nix

    ./conf-cli/smug_and_skull.nix
  ];

  services.secondbrain.enable = true;

  #  programs.myhotkeys."Gnome Extra".cyclewindow.key = "<ALT>grave";
  #  programs.myhotkeys."Gnome Extra".cyclewindow.description = "Cycle windows within same Application";
  #  programs.myhotkeys.enable = true;
  #  programs.myhotkeys.hotkey_groups = [
  #    {
  #      name = "Gnome Extra";
  #      shortcuts = [
  #        {
  #          key = "<ALT>grave";
  #          description = "Cycle windows within same Application";
  #        }
  #      ];
  #    }
  #
  #  ];
  #

#  dconf.settings = {
#    "org/gnome/desktop/input-sources" = {
#      per-window = false;
#      sources = [ (mkTuple [ "xkb" "us" ]) ];
#      xkb-options = [
#        "altwin:swap_alt_win"
#
#        "grp:alt_shift_toggle"
#        "lv3:ralt_switch"
#        "compose:ralt"
#        "caps:none"
#      ];
#    };
#  };


}
