{ config, lib, ... }:

with lib;

let
  cfg = config.programs.powerline-rs;
in
{
  options = {
    programs.powerline-rs = {
      enable = mkEnableOption "powerline-rs";
    };
  };
  config = mkIf cfg.enable {
    programs.bash.initExtra = ''
      powerline() {
        PS1="$(powerline-rs --shell bash $?)"
      }
      PROMPT_COMMAND=powerline
    '';
    programs.fish.promptInit = ''
      function fish_prompt
          powerline-rs --shell bare $status
      end
    '';
    programs.zsh.initExtra = ''
      powerline() {
        local exit_code="$?"
        if [[ "$TERM" == eterm* ]]; then
            PS1="''${PWD/$HOME/~} %% "
        else
            PS1="$(powerline-rs --shell zsh "$exit_code")"
        fi
      }
      precmd_functions+=(powerline)
    '';
  };
}
