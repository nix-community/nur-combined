{ config, pkgs, lib, data, ... }:
let
  # cfg = config.services.prometheus;
  targets = map (n: "${n}.nyaw.xyz") [ "nodens" "colour" ];
in
{

  systemd.services.prometheus.serviceConfig.LoadCredential = (map (lib.genCredPath config)) [
    "wg"
  ];

  services.prometheus = {
    enable = true;
    webExternalUrl = "https://colour.nyaw.xyz/prom";
    listenAddress = "0.0.0.0";
    port = 9090;
    retentionTime = "7d";
    globalConfig = {
      scrape_interval = "1m";
      evaluation_interval = "1m";
    };
    scrapeConfigs = [
      {
        job_name = "caddy";
        scheme = "https";
        basic_auth = {
          username = "prometheus";
          password_file = "/run/credentials/prometheus.service/wg";
        };
        metrics_path = "/caddy";
        static_configs = [{ inherit targets; }];
      }
      {
        job_name = "dns";
        metrics_path = "/metrics";
        static_configs = [{ targets = [ "localhost:9092" ]; }];
      }
    ];
    rules = lib.singleton (builtins.toJSON {
      groups = [{
        name = "metrics";
        rules = [
          {
            alert = "NodeDown";
            expr = ''up == 0'';
          }
          {
            alert = "OOM";
            expr = ''node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.1'';
          }
          {
            alert = "DiskFull";
            expr = ''node_filesystem_avail_bytes{mountpoint=~"/persist|/data"} / node_filesystem_size_bytes < 0.1'';
          }
          {
            alert = "UnitFailed";
            expr = ''node_systemd_unit_state{state="failed"} == 1'';
          }
        ];
      }];
    });
    alertmanagers = [{
      static_configs = [{
        targets = [ "127.0.0.1:8009" ];
      }];
    }];

    exporters = {
      node = {
        enable = true;
        listenAddress = "127.0.0.1";
        enabledCollectors = [ "systemd" ];
        disabledCollectors = [ "arp" ];
      };
      blackbox = {
        enable = true;
        listenAddress = "127.0.0.1";
        configFile = (pkgs.formats.yaml { }).generate "config.yml" {
          modules = {
            http_2xx = {
              prober = "http";
            };
          };
        };
      };
    };
  };
}
