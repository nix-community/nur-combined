{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    sensibleOnTop = true;
    newSession = false;
    shortcut = "a";
    historyLimit = 5000;
    plugins = [
      pkgs.tmuxPlugins.urlview
    ];

    extraConfig = ''
      set -s escape-time 10                     # faster command sequences
      set -sg repeat-time 600                   # increase repeat timeout

      set -s focus-events on

      set -g base-index 1           # start windows numbering at 1
      setw -g pane-base-index 1     # make pane numbering consistent with windows

      setw -g automatic-rename off  # rename window to reflect current program
      set -g renumber-windows on    # renumber windows when a window is closed

      set -g set-titles on          # set terminal title
      set-option -g set-titles-string '#S'

      set -g display-panes-time 800 # slightly longer pane indicators display time
      set -g display-time 1000      # slightly longer status messages display time

      set -g status-interval 300     # redraw status line in seconds

      # activity
      set -g monitor-activity off
      set -g visual-activity off

      #COPYPASTE
      set-window-option -g mode-keys vi
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi V send -X select-line
      bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

      unbind C-a
      bind Tab last-window        # move to last active window

      bind s choose-tree -sZ -O name

      # START WITH MOUSE MODE ENABLED
      set -g mouse on

      if '[ -f ~/.tmux/gpakosz.cf ]' 'source ~/.tmux/gpakosz.cf'
      run 'cat ~/.tmux/gpakosz.sh | sh -s _apply_configuration'

    '';
  };
}
