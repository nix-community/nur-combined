{
  home-manager.sharedModules = [
    ({
      config,
      pkgs,
      ...
    }: {
      home.packages = [pkgs.zed-preview-bin];

      # Zed writes settings atomically, so the complete directory must remain writable.
      xdg.configFile."zed".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Configs/zed";
    })
  ];
}
