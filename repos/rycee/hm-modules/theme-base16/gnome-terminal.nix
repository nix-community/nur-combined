{ config, lib, ... }:

let

  colors = config.theme.base16.colors;

in {
  options.programs.gnome-terminal.enableBase16Theme = lib.mkOption {
    type = lib.types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };

  config = lib.mkIf config.programs.gnome-terminal.enableBase16Theme {
    # Adapted from https://github.com/aaron-williamson/base16-gnome-terminal/.
    programs.gnome-terminal = {
      themeVariant = config.theme.base16.kind;
      profile."5ddfe964-7ee6-4131-b449-26bdd97518f7" = {
        visibleName = "Home Manager - Base16";
        colors = {
          backgroundColor = "#${colors.base00.hex.rgb}";
          foregroundColor = "#${colors.base05.hex.rgb}";
          cursor = {
            background = "#${colors.base05.hex.rgb}";
            foreground = "#${colors.base00.hex.rgb}";
          };
          palette = [
            "#${colors.base00.hex.rgb}"
            "#${colors.base08.hex.rgb}"
            "#${colors.base0B.hex.rgb}"
            "#${colors.base0A.hex.rgb}"
            "#${colors.base0D.hex.rgb}"
            "#${colors.base0E.hex.rgb}"
            "#${colors.base0C.hex.rgb}"
            "#${colors.base05.hex.rgb}"
            "#${colors.base03.hex.rgb}"
            "#${colors.base09.hex.rgb}"
            "#${colors.base01.hex.rgb}"
            "#${colors.base02.hex.rgb}"
            "#${colors.base04.hex.rgb}"
            "#${colors.base06.hex.rgb}"
            "#${colors.base0F.hex.rgb}"
            "#${colors.base07.hex.rgb}"
          ];
        };
      };
    };
  };
}
