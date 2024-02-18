{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 10;
    shell = "${pkgs.fish}/bin/fish";
    keyMode = "vi";
    terminal = "alacritty";
    extraConfig = ''
      # set -g status off
      set -g set-clipboard on
      set -g status-right ""
      set -g mouse on
      set -g renumber-windows on
      set -ga terminal-overrides ",alacritty:Tc"
      set -g status-style bg=colour246
      new-session -s main
    '';
  };
}
