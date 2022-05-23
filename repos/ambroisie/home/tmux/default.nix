{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.tmux;
  hasGUI = config.my.home.x.enable || (config.my.home.wm != null);
in
{
  options.my.home.tmux = with lib.my; {
    enable = mkDisableOption "tmux terminal multiplexer";
  };

  config.programs.tmux = lib.mkIf cfg.enable {
    enable = true;

    keyMode = "vi"; # Home-row keys and other niceties
    clock24 = true; # I'm one of those heathens
    escapeTime = 0; # Let vim do its thing instead
    historyLimit = 50000; # Bigger buffer
    terminal = "tmux-256color"; # I want accurate termcap info

    plugins = with pkgs.tmuxPlugins; [
      # Open high-lighted files in copy mode
      open
      # Better pane management
      pain-control
      # Better session management
      sessionist
      (lib.optionalAttrs hasGUI {
        # X clipboard integration
        plugin = yank;
        extraConfig = ''
          # Use 'clipboard' because of misbehaving apps (e.g: firefox)
          set -g @yank_selection_mouse 'clipboard'
          # Stay in copy mode after yanking
          set -g @yank_action 'copy-pipe'
        '';
      })
      {
        # Show when prefix has been pressed
        plugin = prefix-highlight;
        extraConfig = ''
          # Also show when I'm in copy or sync mode
          set -g @prefix_highlight_show_copy_mode 'on'
          set -g @prefix_highlight_show_sync_mode 'on'
          # Show prefix mode in status bar
          set -g status-right '#{prefix_highlight} %a %Y-%m-%d %H:%M'
        '';
      }
    ];

    extraConfig = ''
      # Better vim mode
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      ${
        lib.optionalString
          (!hasGUI)
          "bind-key -T copy-mode-vi 'y' send -X copy-selection"
      }
      # Block selection in vim mode
      bind-key -Tcopy-mode-vi 'C-v' send -X begin-selection \; send -X rectangle-toggle
    '';
  };
}
