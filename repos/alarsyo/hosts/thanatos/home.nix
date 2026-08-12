{config, ...}: {
  home-manager.users.alarsyo = {
    home.stateVersion = "23.11";

    my.theme = config.home-manager.users.alarsyo.my.themes.solarizedLight;
  };
}
