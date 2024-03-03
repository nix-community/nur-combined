{config, ...}: {
  home-manager.users.alarsyo = {
    home.stateVersion = "22.05";
    my.theme = config.home-manager.users.alarsyo.my.themes.solarizedLight;
  };
}
