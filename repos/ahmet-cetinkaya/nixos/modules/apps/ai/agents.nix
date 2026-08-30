{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    opencode
    claude-code
  ];

  home-manager.sharedModules = [
    ({config, ...}: {
      home.file.".agent-ctrl".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Configs/agent-ctrl";
    })
  ];
}
