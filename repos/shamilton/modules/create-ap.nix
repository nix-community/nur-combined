{ config, lib, pkgs, options,
  modulesPath
}:
with lib;
let
  cfg = config.services.create-ap;
  create-ap = pkgs.callPackage ../pkgs/create_ap { };
in {
  options.services.create-ap = {
    enable = mkEnableOption "Create AP Service";
    devout = mkOption {
      type = types.str;
      default = "wlan0";
      description = "Networking Output Device";
    };
    devin = mkOption {
      type = types.str;
      default = "eth0";
      description = "Networking Input Device";
    };
    SSID = mkOption {
      type = types.str;
      description = "Wifi SSID";
    };
    password = mkOption {
      type = types.str;
      description = "Wifi Password";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.create-ap = {
      wantedBy = [ "multi-user.target" ];
      description = "Create AP Service";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${create-ap}/bin/create_ap ${cfg.devout} ${cfg.devin} ${cfg.SSID} ${cfg.password}";
        Restart = "on-failure";
        RestartSec = 5;
        KillSignal = "SIGINT";
      };
    };
  };
}
