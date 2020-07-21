{ config, lib, ... }:

let

  colors = config.theme.base16.colors;

in {
  options.programs.rofi.enableBase16Theme = lib.mkOption {
    type = lib.types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };

  config = lib.mkIf config.programs.rofi.enableBase16Theme {
    # Adapted from https://gitlab.com/0xdec/base16-rofi.
    programs.rofi.colors = {
      window = {
        background = "#${colors.base00.hex.rgb}";
        border = "#${colors.base05.hex.rgb}";
        separator = "#${colors.base05.hex.rgb}";
      };

      rows = {
        normal = {
          background = "#${colors.base00.hex.rgb}";
          foreground = "#${colors.base05.hex.rgb}";
          backgroundAlt = "#${colors.base00.hex.rgb}";
          highlight = {
            background = "#${colors.base01.hex.rgb}";
            foreground = "#${colors.base06.hex.rgb}";
          };
        };

        active = {
          background = "#${colors.base00.hex.rgb}";
          foreground = "#${colors.base0D.hex.rgb}";
          backgroundAlt = "#${colors.base00.hex.rgb}";
          highlight = {
            background = "#${colors.base0D.hex.rgb}";
            foreground = "#${colors.base00.hex.rgb}";
          };
        };

        urgent = {
          background = "#${colors.base00.hex.rgb}";
          foreground = "#${colors.base08.hex.rgb}";
          backgroundAlt = "#${colors.base00.hex.rgb}";
          highlight = {
            background = "#${colors.base08.hex.rgb}";
            foreground = "#${colors.base00.hex.rgb}";
          };
        };
      };
    };
  };
}
