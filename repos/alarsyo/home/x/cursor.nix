{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.x.cursor;
in
{
  options.my.home.x.cursor.enable = lib.mkEnableOption "X cursor";

  config = lib.mkIf cfg.enable {
    xsession.pointerCursor = {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      # available sizes for capitaine-cursors are:
      # 24, 30, 36, 48, 60, 72
      size = 30;
    };
  };
}
