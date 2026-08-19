{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    singleton
    ;
  cfg = config.abszero.themes.catppuccin;
  ctpCfg = config.catppuccin;

  palette = config.lib.catppuccin.palette.${ctpCfg.flavor}.colors;
in

{
  imports = [ ../../../../lib/modules/themes/catppuccin/catppuccin.nix ];

  options.abszero.themes.catppuccin.niri = {
    enable = mkEnableOption "catppuccin niri theme";
    enableCompactLayout = mkEnableOption "compact layout designed for tablets and small laptops";
  };

  config = mkIf cfg.niri.enable {
    abszero.themes.catppuccin.enable = true;

    # Remove minimize, maximize, close buttons
    dconf.settings."org/gnome/desktop/wm/preferences".button-layout = "";

    wayland.windowManager.niri.settings = mkMerge [
      {
        layout = {
          tab-indicator = {
            place-within-column = { };
            gaps-between-tabs = 4;
            corner-radius = 100;
          };
          focus-ring = {
            active-gradient._props = {
              from = palette.pink.hex;
              to = palette.mauve.hex;
              "in" = "oklab";
              angle = 135;
            };
            inactive-gradient._props = {
              from = palette.lavender.hex;
              to = palette.blue.hex;
              "in" = "oklab";
              angle = 135;
            };
          };
          shadow.on = { };
        };

        _children = singleton { window-rule.clip-to-geometry = true; };
      }

      (mkIf (!cfg.niri.enableCompactLayout) {
        layout = {
          always-center-single-column = { };
          tab-indicator.gap = 8;
          gaps = 24;
          struts = rec {
            top = 24;
            right = top;
            bottom = top;
            left = top;
          };
        };

        _children = singleton { window-rule.geometry-corner-radius = 8; };
      })

      (mkIf cfg.niri.enableCompactLayout {
        layout = {
          tab-indicator.gap = -8;
          focus-ring.width = 6;
          gaps = 0;
          # Hide border outside of the screen
          struts = rec {
            top = -6.4; # Thin line still visible at -6
            right = top;
            bottom = top;
            left = top;
          };
        };

        _children = [
          {
            window-rule = {
              match._props.is-floating = false;
              border = {
                on = { };
                width = 6; # Widen border because smaller screen has lower scale
                active-gradient = {
                  from = palette.pink.hex;
                  to = palette.mauve.hex;
                  "in" = "oklab";
                  angle = 135; # Top left to bottom right
                };
                inactive-color = "#000000";
              };
              focus-ring.off = { };
            };
          }
          {
            match._props.is-floating = true;
            geometry-corner-radius = 10;
          }
        ];
      })
    ];
  };
}
