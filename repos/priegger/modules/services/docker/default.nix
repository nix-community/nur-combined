{ config, lib, pkgs, ... }:

with lib;
let
  metricsAddr = "127.0.0.1:9323";

  cfg = config.priegger.services.docker;
in
{
  options.priegger.services.docker = {
    enable = mkEnableOption "This option enables docker and adds monitoring.";
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      extraOptions = mkIf config.services.prometheus.enable "--config-file=${pkgs.writeText "daemon.json" (
          builtins.toJSON {
              metrics-addr = metricsAddr;
              experimental = true;
              }
          )}";
    };

    services.cadvisor = mkIf config.services.prometheus.enable {
      enable = mkDefault true;
      extraOptions = [ "-housekeeping_interval=15s" "-max_procs=1" ];
      port = mkDefault 18080;
    };

    services.prometheus.scrapeConfigs = mkIf config.services.prometheus.enable [
      {
        job_name = "docker";
        static_configs = [
          { targets = [ metricsAddr ]; }
        ];
      }
      (
        mkIf
          config.services.cadvisor.enable
          {
            job_name = "cadvisor";
            static_configs = [
              { targets = [ "127.0.0.1:${toString config.services.cadvisor.port}" ]; }
            ];
          }
      )
    ];
  };
}
