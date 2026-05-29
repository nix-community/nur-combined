{ config, lib, ... }:
let
  cfg = config.my.home.terminal.alacritty;
  inherit (config.my.home.terminal) colors;
in
{
  options.my.home.terminal = with lib; {
    default = mkOption {
      type = with types; nullOr (enum [ "alacritty" ]);
    };

    alacritty = {
      enable = mkEnableOption "alacritty" // {
        default = config.my.home.terminal.default == "alacritty";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;

      settings = {
        font = {
          size = 5.5;
        };

        colors = {
          primary = {
            background = colors.background;
            foreground = colors.foreground;

            bright_foreground = colors.foregroundBold;
          };

          cursor = {
            cursor = colors.cursor;
          };

          normal = {
            black = colors.black;
            red = colors.red;
            green = colors.green;
            yellow = colors.yellow;
            blue = colors.blue;
            magenta = colors.magenta;
            cyan = colors.cyan;
            white = colors.white;
          };

          bright = {
            black = colors.blackBold;
            red = colors.redBold;
            green = colors.greenBold;
            yellow = colors.yellowBold;
            blue = colors.blueBold;
            magenta = colors.magentaBold;
            cyan = colors.cyanBold;
            white = colors.whiteBold;
          };
        };
      };
    };
  };
}
