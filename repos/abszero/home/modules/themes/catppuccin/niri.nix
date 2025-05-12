{ config, lib, ... }:

let
  inherit (lib) mkIf;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.catppuccin;
  ctpCfg = config.catppuccin;

  palette = config.lib.catppuccin.palette.${ctpCfg.flavor}.colors;
in

{
  imports = [ ../../../../lib/modules/themes/catppuccin/catppuccin.nix ];

  options.abszero.themes.catppuccin.niri.enable =
    mkExternalEnableOption config "catppuccin niri theme";

  config = mkIf cfg.niri.enable {
    abszero.themes.catppuccin.enable = true;

    # Remove minimize, maximize, close buttons
    dconf.settings."org/gnome/desktop/wm/preferences".button-layout = "";

    programs.niri.settings = {
      layout = {
        always-center-single-column = true;

        tab-indicator = {
          place-within-column = true;
          gap = 8;
          gaps-between-tabs = 4;
          corner-radius = 100;
        };

        focus-ring = {
          active.gradient = {
            from = palette.pink.hex;
            to = palette.mauve.hex;
            in' = "oklab";
            angle = 135; # Top left to bottom right
          };
          inactive.gradient = {
            from = palette.lavender.hex;
            to = palette.blue.hex;
            in' = "oklab";
            angle = 135;
          };
        };

        shadow.enable = true;

        gaps = 24;
        struts = rec {
          top = 24;
          right = top;
          bottom = top;
          left = top;
        };
      };

      window-rules = [
        {
          geometry-corner-radius = rec {
            top-left = 8.0;
            top-right = top-left;
            bottom-right = top-left;
            bottom-left = top-left;
          };
          clip-to-geometry = true;
        }
      ];
    };
  };
}
