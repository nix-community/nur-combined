{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    historyLimit = 200000;
    baseIndex = 1;
    terminal = "tmux-256color";
    escapeTime = 100;
    plugins = with pkgs.tmuxPlugins; [ ];
    # https://github.com/dd-ix/nix-config/blob/master/modules/common/tmux.nix
    extraConfig = ''
      set -ga terminal-overrides ",xterm-256color:Tc"
    '';
  };
}
