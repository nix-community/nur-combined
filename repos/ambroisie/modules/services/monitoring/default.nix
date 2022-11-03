# Grafana dashboards for all the things!
{ config, lib, pkgs, ... }:
let
  cfg = config.my.services.monitoring;
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

      scrapeInterval = mkOption {
        type = types.str;
        default = "15s";
        example = "1m";
        description = "Scrape interval";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.grafana = {
      enable = true;

      settings = {
        server = {
          domain = "monitoring.${config.networking.domain}";
          root_url = "https://monitoring.${config.networking.domain}/";
          http_port = cfg.grafana.port;
          http_addr = "127.0.0.1"; # Proxied through Nginx
        };

        security = {
          admin_user = cfg.grafana.username;
          admin_password = "$__file{${cfg.grafana.passwordFile}}";
        };
      };

      provision = {
        enable = true;

        datasources.settings.datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            url = "http://localhost:${toString cfg.prometheus.port}";
            jsonData = {
              timeInterval = cfg.prometheus.scrapeInterval;
            };
          }
        ];

        dashboards.settings.providers = [
          {
            name = "Node Exporter";
            options.path = pkgs.nur.repos.alarsyo.grafanaDashboards.node-exporter;
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

      globalConfig = {
        scrape_interval = cfg.prometheus.scrapeInterval;
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

    my.services.nginx.virtualHosts = [
      {
        subdomain = "monitoring";
        inherit (cfg.grafana) port;
      }
    ];
  };
}
