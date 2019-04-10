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
      type = bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # enable custom docker service
    services.docker.enable = cfg.docker;

    # Add Crostini-specific Bash magic
    programs.bash = {
      enable = true;
      profileExtra = ''
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi
      '';

      bashrcExtra = ''
        # Start up ssh-agent
        eval $(ssh-agent)
      '';
    };
  };
}
