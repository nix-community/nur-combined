{ pkgs, ... }: {

  home.packages = [ pkgs.wezterm ];
  xdg.configFile."wezterm/wezterm.lua".text = builtins.readFile ./wezterm.lua;
}
