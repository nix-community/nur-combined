{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.programs.fzf;
in {
  options = {

    programs.fzf = {
      bash = {
        keyBindings = {
          enable = mkOption {
            type = types.bool;
            default = false;
            description = "Enable the fzf Bash key-bindings and completion.";
          };
        };
      };
    };
  };

  config = mkIf cfg.bash.keyBindings.enable {
    programs.bash.interactiveShellInit = ''
      . ${pkgs.fzf}/share/fzf/completion.bash
    '';

    meta.maintainers = with maintainers; [ emmanuelrosa ];
  };
}
