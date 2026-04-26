{
  programs.fzf.enable = true;
  programs.fish = {
    enable = true;
    shellAliases = {
      noproxy = "env -u http_proxy -u https_proxy -u ftp_proxy -u rsync_proxy -u all_proxy ";
    };
  };
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    settings = {
      theme = "Monokai Classic";
      notify-on-command-finish = "unfocused";
      notify-on-command-finish-action = "notify";
    };
  };
}
