{
  environment.sessionVariables.TERMINAL = "kitty";

  home-manager.sharedModules = [
    ({
      config,
      pkgs,
      ...
    }: {
      home.packages = [pkgs.kitty];
      xdg.configFile."kitty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Configs/kitty";
    })
  ];
}
