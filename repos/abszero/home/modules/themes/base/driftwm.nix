{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf mkMerge;
  cfg = config.abszero.themes.base.driftwm;
in

{
  options.abszero.themes.base.driftwm = {
    enable = mkEnableOption "base driftwm theme";
    enableCompactLayout = mkEnableOption "compact layout designed for tablets and small laptops";
  };

  config = mkIf cfg.enable {
    abszero.programs.driftwm.settings = mkMerge [
      {
        decorations = {
          default_mode = "minimal"; # SSD
          border_width = 6;
        };
      }

      (mkIf (!cfg.enableCompactLayout) {
        snap = {
          gap = 24;
          outer_gap = 36;
          distance = 36;
          break_force = 36;
        };
        decorations = {
          corner_radius = 16;
          border_color = "#00000000";
        };
      })

      (mkIf cfg.enableCompactLayout {
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

    # Remove minimize, maximize, close buttons
    dconf.settings."org/gnome/desktop/wm/preferences".button-layout = "";
  };
}
