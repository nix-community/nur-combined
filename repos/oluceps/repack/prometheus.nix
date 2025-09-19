{
  reIf,
  config,
  pkgs,
  lib,
  ...
}:
let
  targets = map (n: "${n}.nyaw.xyz") (builtins.attrNames lib.data.node);
  gen_relabel_configs = replacement: [
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
      inherit replacement;
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
      "syncthing-hastur-api"
    ];
  };
  services.prometheus = {
    enable = true;
    checkConfig = "syntax-only"; # stat unexist file
    webExternalUrl = "https://${config.networking.fqdn}/prom";
    listenAddress = "[fdcc::3]";
    webConfigFile = (pkgs.formats.yaml { }).generate "web.yaml" {
      basic_auth_users = {
        prometheus = "$2b$05$9CaXvrYtguDwi190/llO9.qytgqCyPp1wqyO0.umxsTEfKkhpwr4q";
      };
    };
    port = 9090;
    retentionTime = "7d";
    globalConfig = {
      scrape_interval = "30s";
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
          job_name = "seaweedfs_metrics";
          scheme = "http";
          static_configs = [ { targets = [ "[fdcc::3]:9768" ]; } ];
        }
        {
          job_name = "centre_psql_metrics";
          scheme = "http";
          static_configs = [ { targets = [ "[fdcc::3]:9187" ]; } ];
        }
        {
          job_name = "ntfy_metrics";
          scheme = "http";
          static_configs = [ { targets = [ "[fdcc::4]:9090" ]; } ];
        }
        {
          job_name = "synapse_metrics";
          scheme = "http";
          metrics_path = "/_synapse/metrics";
          static_configs = [ { targets = [ "localhost:9031" ]; } ];
        }
        # {
        #   job_name = "mautrix_tg_metrics";
        #   scheme = "http";
        #   static_configs = [ { targets = [ "[fdcc::3]:8005" ]; } ];
        # }
        {
          job_name = "chrony_metrics";
          scheme = "http";
          scrape_interval = "60s";
          scrape_timeout = "20s";
          static_configs = [
            {
              targets = [
                "[fdcc::3]:9123"
                "[fdcc::2]:9123"
                "[fdcc::1]:9123"
              ];
            }
          ];
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              regex = "\\[fdcc::1\\]:9123";
              target_label = "instance";
              replacement = "hastur.nyaw.xyz";
            }
            {
              source_labels = [ "__address__" ];
              regex = "\\[fdcc::2\\]:9123";
              target_label = "instance";
              replacement = "kaambl.nyaw.xyz";
            }
            {
              source_labels = [ "__address__" ];
              regex = "\\[fdcc::3\\]:9123";
              target_label = "instance";
              replacement = "eihort.nyaw.xyz";
            }
          ];
        }
        {
          job_name = "syncthing_metrics";
          scheme = "http";
          static_configs = [
            {
              targets = [
                "[fdcc::1]:8384"
              ];
            }
          ];
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              regex = "\\[fdcc::1\\]:8384";
              target_label = "instance";
              replacement = "hastur.nyaw.xyz";
            }
          ];

          authorization.credentials_file = "/run/credentials/prometheus.service/syncthing-hastur-api";

        }
        {
          job_name = "garage_metrics";
          scheme = "http";
          static_configs = [
            {
              targets = [
                "[fdcc::1]:3903"
                "[fdcc::2]:3903"
              ];
            }
          ];
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              regex = "\\[fdcc::1\\]:3903";
              target_label = "instance";
              replacement = "hastur.nyaw.xyz";
            }
            {
              source_labels = [ "__address__" ];
              regex = "\\[fdcc::2\\]:3903";
              target_label = "instance";
              replacement = "kaambl.nyaw.xyz";
            }
          ];
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
              ]
              ++ map (pre: "https://${pre}.nyaw.xyz") [
                "blog"
                "status"
                "abhoth"
              ];
            }
          ];
          relabel_configs = gen_relabel_configs (
            with config.services.prometheus.exporters.blackbox; "${listenAddress}:${toString port}"
          );
        }
        {
          job_name = "tcp";
          scheme = "http";
          metrics_path = "/probe";
          params = {
            module = [ "tcp_connect" ];
          };
          static_configs = [
            {
              targets = [
                "[2001:4860:4860::8888]:53" # google
                "103.213.4.159:80" # hk1
                "[2401:5a0:1000:96::a]:80"

                "154.31.114.112:80" # jp1
                "[2403:18c0:1000:13a:343b:65ff:fe1b:7a0f]:80"

                "45.95.212.129:80" # jp2
              ];
            }
          ];
          relabel_configs = gen_relabel_configs (
            with config.services.prometheus.exporters.blackbox; "${listenAddress}:${toString port}"
          );
        }
        {
          job_name = "ping";
          scheme = "http";
          metrics_path = "/probe";
          params = {
            module = [ "icmp" ];
          };
          static_configs = [
            {
              targets = [ "8.8.8.8" ];
              labels = {
                name = "GOOGLE";
                code = "ANYCAST";
                ip = "IPv4";
              };
            }
            {
              targets = [ "2001:4860:4860::8888" ];
              labels = {
                name = "GOOGLE";
                code = "ANYCAST";
                ip = "IPv6";
              };
            }
            {
              targets = [ "223.6.6.6" ];
              labels = {
                name = "ALI";
                code = "ANYCAST";
                ip = "IPv4";
              };
            }
            {
              targets = [ "103.213.4.159" ];
              labels = {
                name = "HK1";
                city = "HK";
                code = "HKG"; # IATA
                ip = "IPv4";
              };
            }
            {
              targets = [ "2401:5a0:1000:96::a" ];
              labels = {
                name = "HK1";
                city = "HK";
                code = "HKG";
                ip = "IPv6";
              };
            }
            {
              targets = [ "154.31.114.112" ];
              labels = {
                name = "JP1";
                city = "Tokyo";
                code = "NRT";
                ip = "IPv4";
              };
            }
            {
              targets = [ "2403:18c0:1000:13a:343b:65ff:fe1b:7a0f" ];
              labels = {
                name = "JP1";
                city = "Tokyo";
                code = "NRT";
                ip = "IPv6";
              };
            }
            #### DEPRECATE AT 21/09/2025, 12:51:31
            {
              targets = [ "45.95.212.129" ];
              labels = {
                name = "JP2";
                city = "Tokyo";
                code = "NRT";
                ip = "IPv4";
              };
            }
            {
              targets = [ "2405:84c0:8011:3200::" ];
              labels = {
                name = "JP2";
                city = "Tokyo";
                code = "NRT";
                ip = "IPv6";
              };
            }
            #### DEPRECATE AT 21/09/2025, 12:51:31
          ];
          relabel_configs = gen_relabel_configs (
            with config.services.prometheus.exporters.blackbox; "${listenAddress}:${toString port}"
          );
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
                expr = ''up{instance !~ "kaambl.nyaw.xyz|hastur.nyaw.xyz"} == 0''; # suspend or reboot to win
                for = "2m";
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
          {
            name = "chrony";
            rules = [
              {
                record = "instance:chrony_clock_error_seconds:abs";
                expr = ''
                  abs(chrony_tracking_last_offset_seconds)
                  +
                  chrony_tracking_root_dispersion_seconds
                  +
                  (0.5 * chrony_tracking_root_delay_seconds)
                '';
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
            targets =
              let
                cfg = config.services.prometheus;
              in
              [ "${cfg.alertmanager.listenAddress}:${builtins.toString cfg.alertmanager.port}" ];
          }
        ];
      }
    ];
    exporters = {
      blackbox = {
        enable = true;
        # extraFlags = [ "--log.level=debug" ];
        configFile = (pkgs.formats.yaml { }).generate "config.yml" {
          modules = {
            http_2xx = {
              prober = "http";
            };
            icmp = {
              prober = "icmp";
            };
            tcp_connect = {
              prober = "tcp";
              timeout = "5s";
            };
          };
        };
      };
    };
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
                # http_config = {
                #   proxy_url = "http://127.0.0.1:1900";
                # };
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
