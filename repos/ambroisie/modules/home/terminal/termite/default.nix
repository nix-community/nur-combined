{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.terminal;
in
{
  config = lib.mkIf (cfg.program == "termite") {
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
      backgroundColor = cfg.colors.background;
      cursorColor = cfg.colors.cursor;
      foregroundColor = cfg.colors.foreground;
      foregroundBoldColor = cfg.colors.foregroundBold;
      colorsExtra = with cfg.colors; ''
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
