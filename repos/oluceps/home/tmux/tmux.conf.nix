{ pkgs, lib, ... }:
''
  run-shell ${pkgs.tmuxPlugins.sensible.rtp}
  set  -g default-terminal "alacritty"
  set  -g base-index      1
  setw -g pane-base-index 1
  # We need to set default-shell before calling new-session
  set  -g default-shell "${pkgs.fish}/bin/fish"





  set -g status-keys vi
  set -g mode-keys   vi







  set  -g mouse             off
  setw -g aggressive-resize off
  setw -g clock-mode-style  12
  set  -s escape-time       10
  set  -g history-limit     2000


  # set -g status off
  set -g set-clipboard on
  set -g status-right ""
  set -g mouse on
  set -g renumber-windows on
  set -ga terminal-overrides ",alacritty:Tc"
  set -g status-style bg=colour246
  new-session -s main
''
