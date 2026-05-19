{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.themes.base.hyprland.dynamicCursors;
in

{
  options.abszero.themes.base.hyprland.dynamicCursors.enable = mkEnableOption "hypr-dynamic-cursors";

  config.wayland.windowManager.hyprland = mkIf cfg.enable {
    plugins = with pkgs.hyprlandPlugins; [ hypr-dynamic-cursors ];
    settings.plugin.dynamic-cursors = {
      # mode = "stretch";
      shake = {
        threshold = 4; # Shake threshold
        base = 1; # Min magnification level
        speed = 2; # Magnification increase per second
        influence = 2; # Magnification increase by intensity
        limit = 2; # Max magnification level
        timeout = 1000;
      };
      hyprcursor.resolution = 96;
    };
  };
}
