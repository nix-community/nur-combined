{ config, pkgs, lib, ... }:
let
  targets = map (n: "${n}.nyaw.xyz") [
    "nodens"
    # "colour"
    "hastur"
  ];
in
{
  enable = true;
  webExternalUrl = "https://${config.networking.fqdn}/prom";
  listenAddress = "0.0.0.0";
  port = 9090;
  retentionTime = "7d";
  globalConfig = {
    scrape_interval = "1m";
    evaluation_interval = "1m";
  };
  # prometheus not exit when credentials could not be load.
  scrapeConfigs = let secPath = "/run/credentials/prometheus.service/prom"; in [
    {
      job_name = "caddy";
      scheme = "https";
      basic_auth = {
        username = "prometheus";
        password_file = secPath;
      };
      metrics_path = "/caddy";
      static_configs = [{ inherit targets; }];
    }
    {
      job_name = "mosproxy";
      metrics_path = "/metrics";
      static_configs = [{
        targets = [
          # "10.0.1.2:9092"
          "10.0.1.3:9092"
        ];
      }];
    }
    {
      job_name = "metrics";
      scheme = "https";
      basic_auth = {
        username = "prometheus";
        password_file = secPath;
      };
      static_configs = [{ inherit targets; }];
    }

    # {
    #   job_name = "metrics-prv";
    #   scheme = "http";
    #   static_configs = [{
    #     targets = [ "10.0.1.2:9100" "10.0.1.3:9100" ];
    #   }];
    # }
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
          expr = ''node_filesystem_avail_bytes{mountpoint=~"/persist"} / node_filesystem_size_bytes < 0.1'';
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
}
