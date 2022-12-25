{ config, lib, pkgs, ... }:

with lib;
let 
  cfg = config.programs.alacritty.tmux;
  cfg_tmux = config.programs.tmux;
  tmux_startup = ''
    if [ -x "$(command -v tmux)" ] && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ] && [[ "$TERM" == "alacritty" ]]; then
      exec tmux
    fi
  '';
in {
  meta.maintainers = [ wolfangaukang ];

  options.programs.alacritty.tmux = {
    startTmuxOnBash = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Starts TMUX on BASH startup
      '';
    };
    startTmuxOnZsh = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Starts TMUX on ZSH startup
      '';
    };
  };

  config = {
    assertions = [
      {
        assertion = cfg_tmux.enable -> config.programs.tmux.enable;
        message = "TMUX needs to be enabled first through `programs.tmux.enable`";
      }
    ];

    programs = {
      bash.initExtra = mkIf cfg.startTmuxOnBash ''
        ${tmux_startup} 
      '';
      zsh.initExtra = mkIf cfg.startTmuxOnZsh ''
        ${tmux_startup} 
      '';
    };
  };
}
