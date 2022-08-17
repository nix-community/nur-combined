{...}: {
  environment.etc."tmuxconfig".text = builtins.readFile ./tmux.conf;
  programs.tmux = {
    enable = true;
    extraConfig = ''
      source-file /etc/tmuxconfig
    '';
  };
}
