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
      shake.effects = true;
    };
  };
}
