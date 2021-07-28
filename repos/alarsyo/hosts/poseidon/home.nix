{ config, ... }:
{
  home-manager.users.alarsyo = {
    my.home.tmux.enable = true;
    my.home.fish.enable = true;

    my.theme = config.home-manager.users.alarsyo.my.themes.solarizedLight;
  };
}
