{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkDefault;
  cfg = config.abszero.themes.base.pointerCursor;
in

{
  options.abszero.themes.base.pointerCursor.enable = mkEnableOption "base cursor theme";

  config = mkIf cfg.enable {
    home.pointerCursor = {
      enable = true;
      size = mkDefault 48;
      gtk.enable = true;
      hyprcursor.enable = true;
      x11.enable = true;
    };
    programs.niri.settings.cursor = {
      theme = config.home.pointerCursor.name;
      size = config.home.pointerCursor.size;
    };
  };
}
