{ config, lib, ... }:

let

  inherit (lib) mkDefault mkIf mkOption types;

  colors = config.theme.base16.colors;

in {
  options.programs.rofi.enableBase16Theme = mkOption {
    type = types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };

  config = mkIf config.programs.rofi.enableBase16Theme {
    # Adapted from https://gitlab.com/0xdec/base16-rofi.
    programs.rofi.colors = {
      window = {
        background = mkDefault "#${colors.base00.hex.rgb}";
        border = mkDefault "#${colors.base05.hex.rgb}";
        separator = mkDefault "#${colors.base05.hex.rgb}";
      };

      rows = {
        normal = {
          background = mkDefault "#${colors.base00.hex.rgb}";
          foreground = mkDefault "#${colors.base05.hex.rgb}";
          backgroundAlt = mkDefault "#${colors.base00.hex.rgb}";
          highlight = {
            background = mkDefault "#${colors.base01.hex.rgb}";
            foreground = mkDefault "#${colors.base06.hex.rgb}";
          };
        };

        active = {
          background = mkDefault "#${colors.base00.hex.rgb}";
          foreground = mkDefault "#${colors.base0D.hex.rgb}";
          backgroundAlt = mkDefault "#${colors.base00.hex.rgb}";
          highlight = {
            background = mkDefault "#${colors.base0D.hex.rgb}";
            foreground = mkDefault "#${colors.base00.hex.rgb}";
          };
        };

        urgent = {
          background = mkDefault "#${colors.base00.hex.rgb}";
          foreground = mkDefault "#${colors.base08.hex.rgb}";
          backgroundAlt = mkDefault "#${colors.base00.hex.rgb}";
          highlight = {
            background = mkDefault "#${colors.base08.hex.rgb}";
            foreground = mkDefault "#${colors.base00.hex.rgb}";
          };
        };
      };
    };
  };
}
