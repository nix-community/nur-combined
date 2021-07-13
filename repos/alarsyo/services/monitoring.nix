{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.my.services.monitoring;
  domain = config.networking.domain;
in {
  options.my.services.monitoring = {
    enable = mkEnableOption "Enable monitoring";

    domain = mkOption {
      type = types.str;
      default = "monitoring.${config.networking.domain}";
      example = "monitoring.example.com";
      description = "Domain to use in reverse proxy";
    };
  };

  config = mkIf cfg.enable {
    services.grafana = {
      enable = true;
      domain = cfg.domain;
      port = 3000;
      addr = "127.0.0.1";

      provision = {
        enable = true;

        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:${toString config.services.prometheus.port}";
          }
        ];

        dashboards = [
          {
            name = "Node Exporter";
            options.path = pkgs.packages.grafana-dashboards.node-exporter;
            disableDeletion = true;
          }
          {
            name = "NGINX";
            options.path = pkgs.packages.grafana-dashboards.nginx;
            disableDeletion = true;
          }
        ];
      };
    };

    services.prometheus = {
      enable = true;
      port = 9090;
      listenAddress = "127.0.0.1";

      retentionTime = "2y";

      exporters = {
        node = {
          enable = true;
          enabledCollectors = [ "systemd" ];
          port = 9100;
          listenAddress = "127.0.0.1";
        };
      };

      scrapeConfigs = [
        {
          job_name = config.networking.hostName;
          static_configs = [{
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
          }];
        }
      ];
    };

    services.nginx = {
      virtualHosts.${config.services.grafana.domain} = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
          proxyWebsockets = true;
        };

        forceSSL = true;
        useACMEHost = domain;
      };
    };
  };
}
