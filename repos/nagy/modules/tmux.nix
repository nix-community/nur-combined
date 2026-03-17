{
  programs.tmux = {
    enable = true;
    shortcut = "Space";
    clock24 = true;
    # newSession = true;
    terminal = "tmux-direct";
    aggressiveResize = true;
    baseIndex = 1;
    keyMode = "vi";
    extraConfig = ''
      set -g mouse on
      bind C-k clear-history

      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      # unbind '"'
      # unbind %

      # Quick window movement
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R
    '';
  };
}
