{ config, lib, ... }:

let

  colors = config.theme.base16.colors;

in {
  options.services.dunst.enableBase16Theme = lib.mkOption {
    type = lib.types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };

  config = lib.mkIf config.services.dunst.enableBase16Theme {
    # Adapted from https://github.com/khamer/base16-dunst/.
    services.dunst.settings = {
      global = {
        frame_color = "#${colors.base05.hex.rgb}";
        separator_color = "#${colors.base05.hex.rgb}";
      };

      urgency_low = {
        background = "#${colors.base01.hex.rgb}";
        foreground = "#${colors.base03.hex.rgb}";
      };

      urgency_normal = {
        background = "#${colors.base02.hex.rgb}";
        foreground = "#${colors.base05.hex.rgb}";
      };

      urgency_critical = {
        background = "#${colors.base08.hex.rgb}";
        foreground = "#${colors.base06.hex.rgb}";
      };
    };
  };
}
