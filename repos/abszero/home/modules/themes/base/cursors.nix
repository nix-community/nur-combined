{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkDefault;
  cfg = config.abszero.themes.base.pointerCursor;
in

{
  options.abszero.themes.base.pointerCursor.enable = mkEnableOption "base cursor theme";

  config = mkIf cfg.enable {
    abszero.programs.driftwm.settings.cursor = {
      theme = config.home.pointerCursor.name;
      size = config.home.pointerCursor.size;
    };
    home.pointerCursor = {
      enable = true;
      size = mkDefault 48;
      gtk.enable = true;
      hyprcursor.enable = true;
      x11.enable = true;
    };
    wayland.windowManager.niri.settings.cursor = {
      xcursor-theme = config.home.pointerCursor.name;
      xcursor-size = config.home.pointerCursor.size;
    };
  };
}
