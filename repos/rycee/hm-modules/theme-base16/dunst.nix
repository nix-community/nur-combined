{ config, lib, ... }:

let

  inherit (lib) mkDefault mkIf mkOption types;

  colors = config.theme.base16.colors;

in {
  options.services.dunst.enableBase16Theme = mkOption {
    type = types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };

  config = mkIf config.services.dunst.enableBase16Theme {
    # Adapted from https://github.com/khamer/base16-dunst/.
    services.dunst.settings = {
      global = {
        frame_color = mkDefault "#${colors.base05.hex.rgb}";
        separator_color = mkDefault "frame";
      };

      urgency_low = {
        background = mkDefault "#${colors.base01.hex.rgb}";
        foreground = mkDefault "#${colors.base03.hex.rgb}";
      };

      urgency_normal = {
        background = mkDefault "#${colors.base02.hex.rgb}";
        foreground = mkDefault "#${colors.base05.hex.rgb}";
      };

      urgency_critical = {
        background = mkDefault "#${colors.base08.hex.rgb}";
        foreground = mkDefault "#${colors.base06.hex.rgb}";
      };
    };
  };
}
