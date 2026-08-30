{
  home-manager.sharedModules = [
    ({config, ...}: {
      programs.fastfetch.enable = true;

      xdg.configFile = {
        "fastfetch/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Configs/fastfetch/config.jsonc";
        "fastfetch/mini-config.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Configs/fastfetch/mini-config.jsonc";
      };
    })
  ];
}
