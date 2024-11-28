{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.tmux;
  hasGUI = lib.any lib.id [
    config.my.home.x.enable
    (config.my.home.wm.windowManager != null)
  ];

  mkTerminalFlags = opt: flag:
    let
      mkFlag = term: ''set -as terminal-features ",${term}:${flag}"'';
      enabledTerminals = lib.filterAttrs (_: v: v.${opt}) cfg.terminalFeatures;
      terminals = lib.attrNames enabledTerminals;
    in
    lib.concatMapStringsSep "\n" mkFlag terminals;
in
{
  options.my.home.tmux = with lib; {
    enable = my.mkDisableOption "tmux terminal multiplexer";

    enablePassthrough = mkEnableOption "tmux DCS passthrough sequence";

    terminalFeatures = mkOption {
      type = with types; attrsOf (submodule {
        options = {
          hyperlinks = my.mkDisableOption "hyperlinks through OSC8";

          trueColor = my.mkDisableOption "24-bit (RGB) color support";
        };
      });

      default = { ${config.my.home.terminal.program} = { }; };
      defaultText = literalExpression ''
        { ''${config.my.home.terminal.program} = { }; };
      '';
      example = { xterm-256color = { }; };
      description = ''
        $TERM values which should be considered to have additional features.
      '';
    };
  };

  config.programs.tmux = lib.mkIf cfg.enable {
    enable = true;

    keyMode = "vi"; # Home-row keys and other niceties
    clock24 = true; # I'm one of those heathens
    escapeTime = 0; # Let vim do its thing instead
    historyLimit = 100000; # Bigger buffer
    mouse = false; # I dislike mouse support
    terminal = "tmux-256color"; # I want accurate termcap info

    plugins = with pkgs.tmuxPlugins; [
      # Open high-lighted files in copy mode
      open
      # Better pane management
      pain-control
      # Better session management
      sessionist
      {
        # X clipboard integration
        plugin = yank;
        extraConfig = ''
          # Use 'clipboard' because of misbehaving apps (e.g: firefox)
          set -g @yank_selection_mouse 'clipboard'
          # Stay in copy mode after yanking
          set -g @yank_action 'copy-pipe'
        '';
      }
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
      # Refresh configuration
      bind-key -N "Source tmux.conf" R source-file ${config.xdg.configHome}/tmux/tmux.conf \; display-message "Sourced tmux.conf!"

      # Accept sloppy Ctrl key when switching windows, on top of default mapping
      bind-key -N "Select the previous window" C-p previous-window
      bind-key -N "Select the next window" C-n next -window

      # Better vim mode
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      ${
        lib.optionalString
          (!hasGUI)
          "bind-key -T copy-mode-vi 'y' send -X copy-selection"
      }
      # Block selection in vim mode
      bind-key -Tcopy-mode-vi 'C-v' send -X begin-selection \; send -X rectangle-toggle

      # Allow any application to send OSC52 escapes to set the clipboard
      set -s set-clipboard on

      # Longer session names in status bar
      set -g status-left-length 16

      ${
        lib.optionalString cfg.enablePassthrough ''
          # Allow any application to use the tmux DCS for passthrough
          set -g allow-passthrough on
        ''
      }

      # Force OSC8 hyperlinks for each relevant $TERM
      ${mkTerminalFlags "hyperlinks" "hyperlinks"}
      # Force 24-bit color for each relevant $TERM
      ${mkTerminalFlags "trueColor" "RGB"}
    '';
  };
}
