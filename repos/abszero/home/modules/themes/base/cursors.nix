{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.base.pointerCursor;
in

{
  options.abszero.themes.base.pointerCursor.enable = mkEnableOption "base cursor theme";

  config.programs.niri.settings.cursor = mkIf cfg.enable {
    theme = config.home.pointerCursor.name;
    size = config.home.pointerCursor.size;
  };
}
