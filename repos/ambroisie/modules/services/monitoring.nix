# Grafana dashboards for all the things!
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.monitoring;

  domain = config.networking.domain;
  grafanaDomain = "monitoring.${config.networking.domain}";
in
{
  options.my.services.monitoring = with lib; {
    enable = mkEnableOption "monitoring";

    grafana = {
      port = mkOption {
        type = types.port;
        default = 9500;
        example = 3001;
        description = "Internal port";
      };

      username = mkOption {
        type = types.str;
        default = "ambroisie";
        example = "admin";
        description = "Admin username";
      };

      passwordFile = mkOption {
        type = types.str;
        example = "/var/lib/grafana/password.txt";
        description = "Admin password stored in a file";
      };
    };

    prometheus = {
      port = mkOption {
        type = types.port;
        default = 9501;
        example = 3002;
        description = "Internal port";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;
      domain = grafanaDomain;
      port = cfg.grafana.port;
      addr = "127.0.0.1"; # Proxied through Nginx

      security = {
        adminUser = cfg.grafana.username;
        adminPasswordFile = cfg.grafana.passwordFile;
      };

      provision = {
        enable = true;

        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:${toString cfg.prometheus.port}";
          }
        ];

        dashboards = [
          {
            name = "Node Exporter";
            options.path = pkgs.nur.repos.alarsyo.grafana-dashboards.node-exporter;
            disableDeletion = true;
          }
        ];
      };
    };

    services.prometheus = {
      enable = true;
      port = cfg.prometheus.port;
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
      virtualHosts.${grafanaDomain} = {
        forceSSL = true;
        useACMEHost = domain;

        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.grafana.port}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
