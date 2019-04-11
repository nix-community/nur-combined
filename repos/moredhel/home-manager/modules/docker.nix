{ config, lib, pkgs, ... }:

with lib;

let

  name = "docker";

  cfg = config.services.docker;

in {

  ###### interface

  options = {

    services.docker = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable Docker
        '';
      };

      sudo = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to use Sudo to run docker (necessary for Crostini)
        '';
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    home.packages = [pkgs.docker];
    systemd.user.services.docker = {
      Unit = {
        After = [ "network.target" ];
        Description = "Docker";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };

      Service = {
        ExecStart = "${if cfg.sudo then "/usr/bin/sudo" else ""} ${pkgs.docker}/bin/dockerd -G users";
        Type = "daemon";
      };
    };
  };

}
