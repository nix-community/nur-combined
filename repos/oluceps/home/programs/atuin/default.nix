{
  osConfig,
  lib,
  config,
  ...
}:
{
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    # enableZshIntegration = lib.mkIf osConfig.programs.zsh.enable true;
    # enableNushellIntegration = lib.mkIf osConfig.programs.nushell.enable true;
    enableFishIntegration = true;
    settings = {
      auto_sync = true;
      dialect = "us";
      sync_frequency = "10m";
      sync_address = "https://api.atuin.nyaw.xyz";
      search_mode = "fuzzy"; # 'prefix' | 'fulltext' | 'fuzzy'
      sync.record = true;

      ##: options: 'global' (default) | 'host' | 'session' | 'directory'
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "directory";

      key_path = osConfig.age.secrets.atuin_key.path;
    };
  };
}
