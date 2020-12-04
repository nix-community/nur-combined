{ config, lib, pkgs, ... }:

with lib;

let cfg = config.services.fancontrol;
in {
  options.services.fancontrol = {
    enable = mkEnableOption "fancontrol from lm_sensors";

    package = mkOption {
      type = types.package;
      default = pkgs.lm_sensors;
      defaultText = "pkgs.lm_sensors";
      description = ''
        The package used for this service.
      '';
    };

    interval = mkOption {
      type = types.int;
      default = 10;
      description = ''
        The polling interval.
      '';
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Extra content of /etc/fanconfig. You should generate this configuration by running pwmconfig, after loading the necessary kernel modules.
      '';
    };

    extraModules = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Extra kernel modules to load for sensors. These are suggested by sensors-detect.
      '';
    };
  };

  config = mkIf cfg.enable {
    boot.kernelModules = cfg.extraModules;

    environment = {
      etc."fancontrol".text = ''
        INTERVAL=${toString cfg.interval}
        ${cfg.extraConfig}
      '';
      systemPackages = [ cfg.package ];
    };

    systemd.services.fancontrol = {
      description = "Fan speed manager from lm_sensors";
      wantedBy = [ "sysinit.target" ];
      after = [ "syslog.target" "sysinit.target" ];
      restartTriggers = [ config.environment.etc."fancontrol".source ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/fancontrol";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        Restart = "always";
      };
    };
  };
}

