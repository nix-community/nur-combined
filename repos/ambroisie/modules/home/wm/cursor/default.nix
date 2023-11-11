{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.wm.cursor;

  cfg_x = config.my.home.x;
  cfg_gtk = config.my.home.gtk;
in
{
  config = lib.mkIf cfg.enable {
    home.pointerCursor = {
      package = pkgs.ambroisie.vimix-cursors;
      name = "Vimix-cursors";

      x11 = {
        inherit (cfg_x) enable;
      };

      gtk = {
        inherit (cfg_gtk) enable;
      };
    };
  };
}
