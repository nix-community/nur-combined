{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.tmux;
in
{
  options.my.home.tmux = with lib.my; {
    enable = mkDisableOption "tmux terminal multiplexer";

    service = {
      enable = mkDisableOption "tmux server service";
    };
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
      # X clipboard integration
      yank
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
      bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel
    '';
  };

  config.systemd.user.services.tmux = lib.mkIf cfg.service.enable {
    Unit = {
      Description = "tmux server";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };

    Service =
      let
        # Wrap `tmux` in a login shell and set the socket path
        tmuxCmd = "${config.programs.tmux.package}/bin/tmux";
        socketExport = lib.optionalString
          config.programs.tmux.secureSocket
          ''export TMUX_TMPDIR=''${XDG_RUNTIME_DIR:-"/run/user/\$(id -u)"};'';
        mkTmuxCommand =
          c: "${pkgs.runtimeShell} -l -c '${socketExport} ${tmuxCmd} ${c}'";
      in
      {
        Type = "forking";
        ExecStart = mkTmuxCommand "new -d -s ambroisie";
        ExecStop = mkTmuxCommand "kill-server";
      };
  };
}
