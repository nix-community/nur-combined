{ pkgs, ... }:
{
  xdg.configFile."bspwm/bspwmrc".text = builtins.readFile ./bspwmrc;

  xdg.configFile."sxhkd/sxhkdrc".text = builtins.readFile ./sxhkdrc;

}
