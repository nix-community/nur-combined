{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.base.hyprland.dynamicCursors;
in

{
  imports = [ ../../../../lib/modules/config/abszero.nix ];

  options.abszero.themes.base.hyprland.dynamicCursors.enable =
    mkExternalEnableOption config "hypr-dynamic-cursors";

  config.wayland.windowManager.hyprland = mkIf cfg.enable {
    plugins = with pkgs.hyprlandPlugins; [ hypr-dynamic-cursors ];
    settings.plugin.dynamic-cursors = {
      mode = "stretch";
      shake = {
        effects = true;
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
