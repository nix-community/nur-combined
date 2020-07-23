{ config, lib, ... }:

let

  inherit (lib) mkDefault mkIf mkOption types;

  colors = config.theme.base16.colors;

in {
  options.programs.gnome-terminal.enableBase16Theme = mkOption {
    type = types.bool;
    default = true;
    example = false;
    description = "Enable Base16 theme.";
  };

  config = mkIf config.programs.gnome-terminal.enableBase16Theme {
    # Adapted from https://github.com/aaron-williamson/base16-gnome-terminal/.
    programs.gnome-terminal = {
      themeVariant = config.theme.base16.kind;
      profile."5ddfe964-7ee6-4131-b449-26bdd97518f7" = {
        visibleName = mkDefault "Home Manager - Base16";
        colors = {
          backgroundColor = mkDefault "#${colors.base00.hex.rgb}";
          foregroundColor = mkDefault "#${colors.base05.hex.rgb}";
          cursor = {
            background = mkDefault "#${colors.base05.hex.rgb}";
            foreground = mkDefault "#${colors.base00.hex.rgb}";
          };
          palette = mkDefault [
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
