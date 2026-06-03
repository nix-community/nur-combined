{ config, lib, ... }:
let
  cfg = config.my.home.terminal;
in
{
  config = lib.mkIf (cfg.program == "alacritty") {
    programs.alacritty = {
      enable = true;

      settings = {
        font = {
          size = 5.5;
        };

        colors = {
          primary = {
            background = cfg.colors.background;
            foreground = cfg.colors.foreground;

            bright_foreground = cfg.colors.foregroundBold;
          };

          cursor = {
            cursor = cfg.colors.cursor;
          };

          normal = {
            black = cfg.colors.black;
            red = cfg.colors.red;
            green = cfg.colors.green;
            yellow = cfg.colors.yellow;
            blue = cfg.colors.blue;
            magenta = cfg.colors.magenta;
            cyan = cfg.colors.cyan;
            white = cfg.colors.white;
          };

          bright = {
            black = cfg.colors.blackBold;
            red = cfg.colors.redBold;
            green = cfg.colors.greenBold;
            yellow = cfg.colors.yellowBold;
            blue = cfg.colors.blueBold;
            magenta = cfg.colors.magentaBold;
            cyan = cfg.colors.cyanBold;
            white = cfg.colors.whiteBold;
          };
        };
      };
    };
  };
}
