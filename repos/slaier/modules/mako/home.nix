{ pkgs, ... }:
{
  home.packages = [ pkgs.mako ];
  xdg.configFile."mako/config".source = pkgs.replaceVars ./mako.ini {
    autoload = "${pkgs.mpvScripts.autoload}/share/mpv/scripts/autoload.lua";
    sound-theme-freedesktop = "${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga";
  };
}
