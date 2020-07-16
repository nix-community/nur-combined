{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.powerline-rs;
  powerline-rs = "${cfg.package}/bin/powerline-rs";
in
{
  options.programs.powerline-rs = {
    enable = mkEnableOption "powerline-rs";
    package = mkOption {
      type = types.package;
      default = pkgs.powerline-rs;
      description = ''
        The powerline-rs package to use. Defaults to the latest one in nixpkgs.
      '';
    };
    args = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        Extra command line arguments passed to powerline-rs
      '';
    };
  };
  config = mkIf cfg.enable {
    programs.bash.promptInit = ''
      powerline() {
        local exit_code="$?"
        if [[ "$TERM" == eterm* ]]; then
          PS1="''${PWD/$HOME/\~} % "
        else
          PS1="$(${powerline-rs} --shell bash ${escapeShellArgs cfg.args} "$exit_code")"
        fi
      }
      PROMPT_COMMAND=powerline
    '';
    programs.fish.promptInit = ''
      function fish_prompt
          set exit_code $status
          if string match -q "eterm*" "$TERM"
            echo (string replace "$HOME" "~" (pwd))" % "
          else
            ${powerline-rs} --shell bare ${escapeShellArgs cfg.args} $exit_code
          end
      end
    '';
    programs.zsh.promptInit = ''
      powerline() {
        local exit_code="$?"
        if [[ "$TERM" == eterm* ]]; then
          PS1="''${PWD/$HOME/~} %% "
        else
          PS1="$(${powerline-rs} --shell zsh ${escapeShellArgs cfg.args} "$exit_code")"
        fi
      }
      precmd_functions+=(powerline)
    '';
  };
}
