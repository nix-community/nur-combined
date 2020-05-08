{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.priegger.services.nginx;
in
{
  options.priegger.services.nginx = {
    enable = mkEnableOption "Enable the Nginx Web Server, set some defaults and enable monitoring.";
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;

      recommendedProxySettings = mkDefault true;
      recommendedOptimisation = mkDefault true;
      recommendedTlsSettings = mkDefault true;
      recommendedGzipSettings = mkDefault true;

      sslDhparam = mkIf config.security.dhparams.enable config.security.dhparams.params.nginx.path;

      statusPage = mkIf config.services.prometheus.exporters.nginx.enable true;
    };

    security.dhparams = {
      enable = mkDefault true;
      defaultBitSize = mkDefault 4096;

      params.nginx = {};
    };

    services.prometheus = mkIf config.services.prometheus.enable {
      exporters.nginx = {
        enable = mkDefault true;
      };

      scrapeConfigs = [
        (
          mkIf config.services.prometheus.exporters.nginx.enable {
            job_name = "nginx";
            static_configs = [
              { targets = [ "${config.networking.hostName}:${toString config.services.prometheus.exporters.nginx.port}" ]; }
            ];
          }
        )
      ];
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
