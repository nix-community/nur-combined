{ config, pkgs, lib, data, ... }:
let
  # cfg = config.services.prometheus;
  targets = map (n: "${n}.nyaw.xyz") [ "nodens" "colour" ];
in
{
  services.prometheus = {
    enable = true;
    webExternalUrl = "https://colour.nyaw.xyz/prom";
    listenAddress = "10.0.2.2";
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
          password_file = config.age.secrets.wg.path;
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
    # alertmanagers = [{
    #   static_configs = [{
    #     targets = [ "127.0.0.1:8009" ];
    #   }];
    # }];
  };

  # cloud.services.prometheus-ntfy-bridge.config = {
  #   ExecStart = "${pkgs.deno}/bin/deno run --allow-env --allow-net --no-check ${../../../fn/alert.ts}";
  #   MemoryDenyWriteExecute = false;
  #   EnvironmentFile = [ config.sops.secrets.alert.path ];
  #   Environment = [ "PORT=8009" "DENO_DIR=/tmp" ];
  # };

}
