{ pkgs, ... }:
{
  home.packages = [ pkgs.gammastep ];
  xdg.configFile."gammastep/config.ini".source = ./gammastep.ini;
}
