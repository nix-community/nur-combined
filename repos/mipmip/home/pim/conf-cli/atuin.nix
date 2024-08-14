{ config, pkgs, ... }:

{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [
      "--disable-up-arrow"
    ];
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      sync_address = "https://atuin.tools.technative.cloud";
      search_mode = "fuzzy";
    };
  };
}

