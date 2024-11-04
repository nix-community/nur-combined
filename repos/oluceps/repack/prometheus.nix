{
  reIf,
  config,
  pkgs,
  lib,
  ...
}:
let
  targets = map (n: "${n}.nyaw.xyz") [
    "nodens"
  ];
  targets_notls = map (n: "${n}.nyaw.xyz") [
    # "kaambl"
    # "abhoth"
    "yidhra"
    "azasos"
    "yidhra"
    "hastur"
  ];
  relabel_configs = [
    {
      source_labels = [ "__address__" ];
      target_label = "__param_target";
    }
    {
      source_labels = [ "__param_target" ];
      target_label = "instance";
    }
    {
      target_label = "__address__";
      replacement =
        with config.services.prometheus.exporters.blackbox;
        "${listenAddress}:${toString port}";
    }
  ];

in
reIf {
  systemd.services = {
    alertmanager.serviceConfig.LoadCredential = [
      "notifychan:${config.vaultix.secrets.notifychan.path}"
    ];
    prometheus.serviceConfig.LoadCredential = (map (lib.genCredPath config)) [
      "prom"
    ];
  };
  services.prometheus = {
    enable = true;
    webExternalUrl = "https://${config.networking.fqdn}/prom";
    listenAddress = "127.0.0.1";
    webConfigFile = (pkgs.formats.yaml { }).generate "web.yaml" {
      basic_auth_users = {
        prometheus = "$2b$05$bKuO7ehC6wKR28/pfhJZOuNyQFUtF7FwhkPFLwcbCMhfLRNUV54vm";
      };
    };
    port = 9090;
    retentionTime = "7d";
    globalConfig = {
      scrape_interval = "1m";
      evaluation_interval = "1m";
    };
    # prometheus not exit when credentials could not be load.
    scrapeConfigs =
      let
        secPath = "/run/credentials/prometheus.service/prom";
      in
      [
        {
          job_name = "caddy";
          scheme = "https";
          basic_auth = {
            username = "prometheus";
            password_file = secPath;
          };
          metrics_path = "/caddy";
          static_configs = [ { inherit targets; } ];
        }
        {
          job_name = "metrics";
          scheme = "https";
          basic_auth = {
            username = "prometheus";
            password_file = secPath;
          };
          static_configs = [ { inherit targets; } ];
        }
        {
          job_name = "metrics-notls";
          scheme = "http";
          basic_auth = {
            username = "prometheus";
            password_file = secPath;
          };
          static_configs = [ { targets = targets_notls; } ];
        }
        {
          job_name = "http";
          scheme = "http";
          metrics_path = "/probe";
          params = {
            module = [ "http_2xx" ];
          };
          static_configs = [
            {
              targets = [
                "https://nyaw.xyz"
                "https://blog.nyaw.xyz"
                "https://ntfy.nyaw.xyz"
                "https://matrix.nyaw.xyz"
                "https://pb.nyaw.xyz"
                "https://vault.nyaw.xyz"
                "https://status.nyaw.xyz"
              ];
            }
          ];
          inherit relabel_configs;
        }
      ];
    rules = lib.singleton (
      builtins.toJSON {
        groups = [
          {
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
              {
                alert = "BtrfsDevErr";
                expr = ''sum(rate(node_btrfs_device_errors_total[2m])) > 0'';
              }
            ];
          }
        ];
      }
    );
    alertmanagers = [
      {
        path_prefix = "/alert";
        static_configs = [
          {
            targets = (
              let
                cfg = config.services.prometheus;
              in
              [ "${cfg.alertmanager.listenAddress}:${builtins.toString cfg.alertmanager.port}" ]
            );
          }
        ];
      }
    ];
    alertmanager = {
      enable = true;
      webExternalUrl = "https://${config.networking.fqdn}/alert";
      listenAddress = "127.0.0.1";
      port = 9093;
      logLevel = "info";
      extraFlags = [ ''--cluster.listen-address=""'' ];
      configuration = {
        receivers = [
          {
            name = "telegram";
            telegram_configs = [
              {
                bot_token_file = "/run/credentials/alertmanager.service/notifychan";
                chat_id = -1002215131569;
                http_config = {
                  proxy_url = "http://127.0.0.1:1900";
                };
              }
            ];
          }
        ];
        route = {
          receiver = "telegram";
          group_wait = "30s";
          group_interval = "2m";
          repeat_interval = "10m";
        };
      };
    };
  };
}
