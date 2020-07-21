{ config, lib, ... }:

let

  colors = config.theme.base16.colors;

in {
  options.services.polybar.enableBase16Theme = lib.mkOption {
    type = lib.types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };
  config = lib.mkIf config.services.polybar.enableBase16Theme {
    services.polybar.config = {
      colors = {
        background = "#${colors.base01.hex.rgb}";
        foreground = "#${colors.base05.hex.rgb}";
        highlight = "#${colors.base06.hex.rgb}";
        important = "#${colors.base08.hex.rgb}";
        unimportant = "#${colors.base03.hex.rgb}";
      };

      "module/battery" = {
        format-discharging-foreground = "\${colors.important}";
      };

      "module/xworkspaces" = {
        label-active-foreground = "\${colors.highlight}";
        label-urgent-foreground = "\${colors.important}";
        label-occupied-foreground = "\${colors.foreground}";
        label-empty-foreground = "\${colors.unimportant}";
      };

      "module/wireless-network" = {
        format-disconnected-foreground = "\${colors.unimportant}";
      };

      "module/wired-network" = {
        format-disconnected-foreground = "\${colors.unimportant}";
      };
    };
  };
}
