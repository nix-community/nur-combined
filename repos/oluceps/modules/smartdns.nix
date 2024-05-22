{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.smartdns;
in
{
  disabledModules = [ "services/networking/smartdns.nix" ];

  options = {
    services.smartdns = {
      enable = lib.mkEnableOption "smartdns";
      package = lib.mkPackageOption pkgs "smartdns-rs" { };
      config = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = {
      services.smartdns = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        unitConfig = {
          StartLimitBurst = 0;
          StartLimitIntervalSec = 60;
        };

        serviceConfig = {
          Type = "simple";
          ExecStart = "${lib.getExe cfg.package} run -c ${pkgs.writeText "smartdns.conf" cfg.config} -p /var/run/smartdns.pid -v";
          CapabilityBoundingSet = [
            "CAP_NET_ADMIN"
            "CAP_NET_RAW"
            "CAP_NET_BIND_SERVICE"
          ];
          AmbientCapabilities = [
            "CAP_NET_ADMIN"
            "CAP_NET_RAW"
            "CAP_NET_BIND_SERVICE"
          ];
          PIDFile = "/var/run/smartdns.pid";
          Restart = "always";
          RestartSec = 2;
          TimeoutStopSec = 15;
        };
      };
    };
  };
}
