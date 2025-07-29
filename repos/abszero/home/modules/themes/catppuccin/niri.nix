{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    singleton
    ;
  inherit (lib.abszero.modules) mkExternalEnableOption;
  cfg = config.abszero.themes.catppuccin;
  ctpCfg = config.catppuccin;

  palette = config.lib.catppuccin.palette.${ctpCfg.flavor}.colors;
in

{
  imports = [ ../../../../lib/modules/themes/catppuccin/catppuccin.nix ];

  options.abszero.themes.catppuccin.niri = {
    enable = mkExternalEnableOption config "catppuccin niri theme";
    enableCompactLayout = mkEnableOption "compact layout designed for tablets and small laptops";
  };

  config = mkIf cfg.niri.enable {
    abszero.themes.catppuccin.enable = true;

    # Remove minimize, maximize, close buttons
    dconf.settings."org/gnome/desktop/wm/preferences".button-layout = "";

    programs.niri.settings = mkMerge [
      {
        layout = {
          tab-indicator = {
            place-within-column = true;
            gaps-between-tabs = 4;
            corner-radius = 100;
          };
          focus-ring = {
            active.gradient = {
              from = palette.pink.hex;
              to = palette.mauve.hex;
              in' = "oklab";
              angle = 135;
            };
            inactive.gradient = {
              from = palette.lavender.hex;
              to = palette.blue.hex;
              in' = "oklab";
              angle = 135;
            };
          };
          shadow.enable = true;
        };

        window-rules = [
          { clip-to-geometry = true; }
        ];
      }

      (mkIf (!cfg.niri.enableCompactLayout) {
        layout = {
          always-center-single-column = true;
          tab-indicator.gap = 8;
          gaps = 24;
          struts = rec {
            top = 24;
            right = top;
            bottom = top;
            left = top;
          };
        };

        window-rules = singleton {
          geometry-corner-radius = rec {
            top-left = 8.0;
            top-right = top-left;
            bottom-right = top-left;
            bottom-left = top-left;
          };
        };
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

        window-rules = [
          {
            border = {
              enable = true;
              width = 6; # Widen border because smaller screen has lower scale
              active.gradient = {
                from = palette.pink.hex;
                to = palette.mauve.hex;
                in' = "oklab";
                angle = 135; # Top left to bottom right
              };
              inactive.color = "#000000";
            };
            focus-ring.enable = false;
            matches = [ { is-floating = false; } ];
          }
          {
            geometry-corner-radius = rec {
              top-left = 10.0;
              top-right = top-left;
              bottom-right = top-left;
              bottom-left = top-left;
            };
            matches = [ { is-floating = true; } ];
          }
        ];
      })
    ];
  };
}
