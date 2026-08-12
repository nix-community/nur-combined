{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkOption
    ;

  cfg = config.my.services.monitoring;
  domain = config.networking.domain;
  hostname = config.networking.hostName;
  fqdn = "${hostname}.${domain}";
in {
  options.my.services.monitoring = let
    inherit (lib) types;
  in {
    enable = mkEnableOption "Enable monitoring";

    domain = mkOption {
      type = types.str;
      default = "monitoring.${config.networking.domain}";
      example = "monitoring.example.com";
      description = "Domain to use in reverse proxy";
    };

    scrapeInterval = mkOption {
      type = types.str;
      default = "15s";
      example = "1m";
      description = "prometheus scrape interval";
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
            jsonData = {
              timeInterval = cfg.scrapeInterval;
            };
          }
        ];

        dashboards = [
          {
            name = "Node Exporter";
            options.path = pkgs.packages.grafanaDashboards.node-exporter;
            disableDeletion = true;
          }
          {
            name = "NGINX";
            options.path = pkgs.packages.grafanaDashboards.nginx;
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
          enabledCollectors = ["systemd"];
          port = 9100;
          listenAddress = "127.0.0.1";
        };
      };

      globalConfig = {
        scrape_interval = cfg.scrapeInterval;
      };

      scrapeConfigs = [
        {
          job_name = config.networking.hostName;
          static_configs = [
            {
              targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
            }
          ];
        }
      ];
    };

    services.nginx = {
      virtualHosts.${cfg.domain} = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
          proxyWebsockets = true;
        };

        forceSSL = true;
        useACMEHost = fqdn;
      };
    };

    security.acme.certs.${fqdn}.extraDomainNames = [cfg.domain];
  };
}
