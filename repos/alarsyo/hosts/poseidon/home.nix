{ config, ... }:
{
  home-manager.users.alarsyo = {
    my.home.tmux.enable = true;
    my.home.fish.enable = true;
  };
}
