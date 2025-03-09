{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.catppuccin;
in

{
  imports = [ ../../../../lib/modules/themes/catppuccin/catppuccin.nix ];

  options.abszero.themes.catppuccin.hyprland.enable =
    mkExternalEnableOption config "catppuccin hyprland theme";

  config = mkIf cfg.hyprland.enable {
    abszero.themes.catppuccin.enable = true;

    catppuccin.hyprland.enable = true;

    # Catppuccin color variables:
    # https://github.com/catppuccin/hyprland/blob/main/themes/frappe.conf
    wayland.windowManager.hyprland.settings = {
      general = {
        border_size = 4;
        gaps_in = 8;
        "col.inactive_border" = "$surface0";
        "col.active_border" = "$accent";
      };

      decoration = {
        rounding = 8;
        blur.enabled = false;
        shadow = {
          range = 8;
          render_power = 2;
          color = "$accent";
        };
      };

      misc = {
        disable_hyprland_logo = true; # Disable default wallpaper
        disable_splash_rendering = true;
        background_color = "$accent";
        animate_manual_resizes = true;
      };

      # https://easings.net
      animation = "global, 1, 5, easeOutQuint";
      bezier = "easeOutQuint, 0.22, 1, 0.36, 1";
    };

    # Remove minimize, maximize, close buttons
    dconf.settings."org/gnome/desktop/wm/preferences".button-layout = "";
  };
}
