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

    wayland.windowManager.hyprland.settings = {
      general = {
        border_size = 4;
        gaps_in = 8;
        "col.inactive_border" = "$surface0";
        "col.active_border" = "$mauve $accent 45deg";
      };

      decoration = {
        rounding = 8;
        blur.enabled = false;
        shadow = {
          range = 8;
          color = "$text";
        };
      };

      misc = {
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
      };

      # https://easings.net
      animation = "global, 1, 5, easeOutQuint";
      bezier = "easeOutQuint, 0.22, 1, 0.36, 1";
    };

    # Remove minimize, maximize, close buttons
    gtk = {
      gtk3.extraConfig.gtk-decoration-layout = "menu:";
      gtk4.extraConfig.gtk-decoration-layout = "menu:";
    };
  };
}
