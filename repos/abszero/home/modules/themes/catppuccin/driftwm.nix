{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.abszero.themes.catppuccin;
  ctpCfg = config.catppuccin;

  palette = config.lib.catppuccin.palette.${ctpCfg.flavor}.colors;
in

{
  imports = [
    ../../../../lib/modules/themes/catppuccin/catppuccin.nix
    ./fonts.nix
  ];

  options.abszero.themes.catppuccin.driftwm = {
    enable = mkEnableOption "catppuccin driftwm theme";
    enableCompactLayout = mkEnableOption "compact layout designed for tablets and small laptops";
  };

  config = mkIf cfg.driftwm.enable {
    abszero = {
      themes.catppuccin = {
        enable = true;
        fonts.enable = true;
      };
      programs.driftwm.settings = mkMerge [
        {
          decorations = {
            default_mode = "minimal"; # SSD
            font = "Maple Mono NF CN";
            font_size = 14;
            border_width = 6;
            border_color_focused = palette.pink.hex;
          };
        }

        (mkIf (!cfg.driftwm.enableCompactLayout) {
          snap = {
            gap = 24;
            distance = 36;
            break_force = 36;
          };
          decorations.border_color = "#00000000";
        })

        (mkIf cfg.driftwm.enableCompactLayout {
          snap = {
            gap = 0;
            distance = 12;
            break_force = 12;
          };
          decorations = {
            corner_radius = 0;
            border_color = "#000000";
          };
        })
      ];
    };

    # Remove minimize, maximize, close buttons
    dconf.settings."org/gnome/desktop/wm/preferences".button-layout = "";
  };
}
