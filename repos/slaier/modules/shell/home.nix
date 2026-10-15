{
  programs.fzf.enable = true;
  programs.fish = {
    enable = true;
    shellAliases = {
      noproxy = "env -u http_proxy -u https_proxy -u ftp_proxy -u rsync_proxy -u all_proxy ";
      listen = "sudo lsof -nP -i 4 -sTCP:LISTEN";
    };
    functions.j2n = ''
      read -xz J2N_JSON
      nix eval --impure --expr 'builtins.fromJSON (builtins.getEnv "J2N_JSON")'
    '';
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
