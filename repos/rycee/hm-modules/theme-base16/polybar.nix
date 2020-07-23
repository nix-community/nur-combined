{ config, lib, ... }:

let

  inherit (lib) mkDefault mkIf mkOption types;

  colors = config.theme.base16.colors;

in {
  options.services.polybar.enableBase16Theme = mkOption {
    type = types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };

  config = mkIf config.services.polybar.enableBase16Theme {
    services.polybar.config = {
      colors = {
        background = mkDefault "#${colors.base01.hex.rgb}";
        foreground = mkDefault "#${colors.base05.hex.rgb}";
        highlight = mkDefault "#${colors.base06.hex.rgb}";
        important = mkDefault "#${colors.base08.hex.rgb}";
        unimportant = mkDefault "#${colors.base03.hex.rgb}";
      };

      "module/battery" = {
        format-discharging-foreground = mkDefault "\${colors.important}";
      };

      "module/xworkspaces" = {
        label-active-foreground = mkDefault "\${colors.highlight}";
        label-urgent-foreground = mkDefault "\${colors.important}";
        label-occupied-foreground = mkDefault "\${colors.foreground}";
        label-empty-foreground = mkDefault "\${colors.unimportant}";
      };

      "module/wireless-network" = {
        format-disconnected-foreground = mkDefault "\${colors.unimportant}";
      };

      "module/wired-network" = {
        format-disconnected-foreground = mkDefault "\${colors.unimportant}";
      };
    };
  };
}
