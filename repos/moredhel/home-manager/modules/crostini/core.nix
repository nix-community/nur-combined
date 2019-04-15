{ config, pkgs, lib, ... }:
with lib;

let
  cfg = config.programs.crostini;
in {
  options.programs.crostini = with types; {
    enable = mkOption {
      type = bool;
      default = false;
    };

    docker = mkOption {
      type = attrs;
      default = {};
    };
  };

  config = mkIf cfg.enable {
    # enable custom docker service
    services.docker = cfg.docker;

    # Add Crostini-specific Bash magic
    programs.bash = {
      enable = true;
      profileExtra = ''
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi
      '';

      bashrcExtra = ''
        # Start up ssh-agent
        if ! pgrep -u "$USER" ssh-agent > /dev/null; then
          ssh-agent > ~/.ssh-agent-thing
        fi
        if [[ ! "$SSH_AUTH_SOCK" ]]; then
          eval "$(<~/.ssh-agent-thing)"
        fi
      '';
    };
  };
}
