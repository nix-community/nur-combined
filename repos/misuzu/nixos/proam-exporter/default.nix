{ config, lib, pkgs, ... }:
let
  cfg = config.services.proam-exporter;
in
{
  options.services.proam-exporter = {
    enable = lib.mkEnableOption "Proam prometheus exporter";
    package = lib.mkPackageOption pkgs "proam-cli" { };
    port = lib.mkOption {
      type = lib.types.port;
      default = 9091;
      description = ''
        TCP port number for exporter to listen to.
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    systemd.services.proam-exporter = {
      description = "Prometheus exporter for Ugreen PowerRoam stations";
      after = [ "network.target" "bluetooth.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ cfg.package ];
      script = ''
        enable -f ${pkgs.bash}/lib/bash/sleep sleep
        if ! proam-cli status > /dev/null 2>&1; then
          while ! proam-cli connect; do
            sleep 1
          done
        fi
        watchdog() {
          while proam-cli status > /dev/null 2>&1; do
            ${config.systemd.package}/bin/systemd-notify WATCHDOG=1
            sleep 2
          done
        }
        watchdog &
        exec proam-cli exporter --port ${toString cfg.port}
      '';
      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        RestartSec = 1;
        StartLimitBurst = 100;
        TimeoutStopSec = 3;
        NotifyAccess = "all";
        WatchdogSec = 6;
        WatchdogSignal = "SIGTERM";
      };
    };
  };
}
