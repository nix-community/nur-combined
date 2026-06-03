{ config, lib, ... }:
let
  mkColorOption = with lib; description: default: mkOption {
    inherit description default;
    example = "#abcdef";
    type = types.strMatching "#[0-9a-f]{6}";
  };

  cfg = config.my.home.terminal;
in
{
  imports = [
    ./alacritty
    ./termite
  ];

  options.my.home = with lib; {
    terminal = {
      program = mkOption {
        type = with types; nullOr (enum [ "alacritty" "termite" ]);
        default = null;
        example = "termite";
        description = "Which terminal to use for home session";
      };

      colors = {
        background = mkColorOption "Background color" "#161616";
        foreground = mkColorOption "Foreground color" "#ffffff";
        foregroundBold = mkColorOption "Foreground bold color" "#ffffff";
        cursor = mkColorOption "Cursor color" "#ffffff";

        black = mkColorOption "Black" "#222222";
        blackBold = mkColorOption "Black bold" "#666666";

        red = mkColorOption "Red" "#e84f4f";
        redBold = mkColorOption "Red bold" "#d23d3d";

        green = mkColorOption "Green" "#b7ce42";
        greenBold = mkColorOption "Green bold" "#bde077";

        yellow = mkColorOption "Yellow" "#fea63c";
        yellowBold = mkColorOption "Yellow bold" "#ffe863";

        blue = mkColorOption "Blue" "#66aabb";
        blueBold = mkColorOption "Blue bold" "#aaccbb";

        magenta = mkColorOption "Magenta" "#b7416e";
        magentaBold = mkColorOption "Magenta bold" "#e16a98";

        cyan = mkColorOption "Cyan" "#6d878d";
        cyanBold = mkColorOption "Cyan bold" "#42717b";

        white = mkColorOption "White" "#dddddd";
        whiteBold = mkColorOption "White bold" "#cccccc";
      };
    };
  };

  config.home.sessionVariables = lib.mkIf (cfg.program != null) {
    TERMINAL = cfg.program;
  };
}
