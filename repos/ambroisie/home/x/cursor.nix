{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.x;
in
{
  config = lib.mkIf cfg.enable {
    xsession.pointerCursor = {
      package = pkgs.numix-cursor-theme;
      name = "Numix-Cursor";
    };
  };
}
