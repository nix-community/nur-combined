{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.batsky;
in {
  #meta.maintainers = [ maintainers.augu5ste ];

  ###### interface
  options.services.batsky = {
    enable = mkEnableOption "batsky";

    package = mkOption {
      type = types.package;
      default = pkgs.nur.repos.kapack.batsky;
      defaultText = " pkgs.nur.repos.kapack.batsky";
    };

    controller = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Hostname which controls the forgered time.
      '';
    };
    args = mkOption {
      type = types.nullOr types.str;
      default = "-d -l /tmp/batsky.log";
      description = ''
        Basic options for Batsky.
      '';
    };
    ctrl_args = mkOption {
      type = types.nullOr types.str;
      default = " '-d -l /tmp/batsky-controller.log'";
      description = ''
        Basic options for controller.
      '';
    };
    
  };

  ###### implementation
  config = mkIf cfg.enable {
    systemd.services.batsky = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "Time forger compagnion of Batsim";
      restartIfChanged = false;
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/batsky ${cfg.args} -c ${cfg.controller} -o ${cfg.ctrl_args}";
        KillMode = "process";
        Restart = "on-failure";
        ExecStartPost = "${pkgs.bash}/bin/bash -c 'while [ ! -S /tmp/batsky/notify.sock ]; do sleep 0.1; done'";
      };
    };
  };
}
