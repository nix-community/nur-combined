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
    programs.tmux = {
      enable = true;
      extraConfig = ''
        source-file ${config.xdg.configHome}/tmux/commons/keybindings
        source-file ${config.xdg.configHome}/tmux/tmux.conf
      '';
    };
    xdg.configFile."tmux/tmux.conf".source = ./assets/tmux/tmux.conf;
    xdg.configFile."tmux/commons/keybindings".source = ./assets/tmux/keybindings;
  };
}
