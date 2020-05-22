{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profiles.tmux;
in
{
  options = {
    profiles.tmux = {
      enable = mkOption {
        default = true;
        description = "Enable tmux profile and configuration";
        type = types.bool;
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      tmux
    ];
    home.file.".tmux.conf".text = ''
      source-file ${config.xdg.configHome}/tmux/tmux.conf
      set-environment -g TMUX_PLUGIN_MANAGER_PATH '${config.xdg.configHome}/tmux/plugins'

      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'tmux-plugins/tmux-resurrect'
      set -g @plugin 'tmux-plugins/tmux-continuum'
      set -g @plugin 'tmux-plugins/tmux-copycat'

      set -g @continuum-restore 'on'

      run '${pkgs.tmux-tpm}/tpm'
    '';
    xdg.configFile."tmux/tmux.conf".source = ./assets/tmux/tmux.conf;
    xdg.configFile."tmux/commons/keybindings".source = ./assets/tmux/keybindings;
  };
}
