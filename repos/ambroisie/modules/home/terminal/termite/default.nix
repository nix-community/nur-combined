{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.terminal.termite;
  inherit (config.my.home.terminal) colors;
in
{
  options.my.home.terminal = with lib; {
    default = mkOption {
      type = with types; nullOr (enum [ "termite" ]);
    };

    termite = {
      enable = mkEnableOption "termite" // {
        default = config.my.home.terminal.default == "termite";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.termite = {
      enable = true;

      # Niceties
      browser = "${pkgs.xdg-utils}/bin/xdg-open";
      clickableUrl = true;
      dynamicTitle = true;
      fullscreen = false;
      mouseAutohide = true;
      urgentOnBell = true;

      # Look and feel
      allowBold = true;
      audibleBell = false;
      cursorBlink = "system";
      font = "Monospace 9";
      scrollbar = "off";


      # Colors
      backgroundColor = colors.background;
      cursorColor = colors.cursor;
      foregroundColor = colors.foreground;
      foregroundBoldColor = colors.foregroundBold;
      colorsExtra = with colors; ''
        # Normal colors
        color0 = ${black}
        color1 = ${red}
        color2 = ${green}
        color3 = ${yellow}
        color4 = ${blue}
        color5 = ${magenta}
        color6 = ${cyan}
        color7 = ${white}
        # Bold colors
        color8 = ${blackBold}
        color9 = ${redBold}
        color10 = ${greenBold}
        color11 = ${yellowBold}
        color12 = ${blueBold}
        color13 = ${magentaBold}
        color14 = ${cyanBold}
        color15 = ${whiteBold}
      '';
    };
  };
}
