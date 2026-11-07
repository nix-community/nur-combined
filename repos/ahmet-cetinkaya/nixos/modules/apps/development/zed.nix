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

      # Keep a hard ceiling for leaked debugger/terminal children, but do not impose
      # MemoryHigh or a tight swap cap: reclaim at those thresholds caused oomd kills.
      xdg.configFile."systemd/user/app-dev.zed.Zed\\x2dPreview@.service.d/resources.conf".text = ''
        [Service]
        MemoryMax=24G
        OOMPolicy=continue
      '';
    })
  ];
}
