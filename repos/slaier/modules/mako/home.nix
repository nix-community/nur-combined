{ pkgs, ... }:
{
  home.packages = [ pkgs.mako ];
  xdg.configFile."mako/config".source = ./mako.ini;
}
