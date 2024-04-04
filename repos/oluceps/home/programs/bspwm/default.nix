{ pkgs, ... }:
{
  xdg.configFile."bspwm/bspwmrc".source = ./bspwmrc;

  xdg.configFile."sxhkd/sxhkdrc".source = ./sxhkdrc;
}
