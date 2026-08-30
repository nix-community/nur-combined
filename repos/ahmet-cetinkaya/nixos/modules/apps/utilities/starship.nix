{
  home-manager.sharedModules = [
    ({config, ...}: {
      programs.starship.enable = true;
      xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Configs/starship/starship.toml";
    })
  ];
}
