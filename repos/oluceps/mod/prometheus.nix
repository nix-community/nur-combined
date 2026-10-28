{ self, ... }:
{
  flake.modules.nixos.prometheus =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      autopeer_challenge_url = "https://dn42.nyaw.xyz/api/challenges";
      autopeer_nodes = [
        {
          name = "abhoth";
          domain = "jp-tyo-1.dn42.nyaw.xyz";
        }
        {
          name = "nodens";
          domain = "jp-tyo-2.dn42.nyaw.xyz";
        }
        {
          name = "yidhra";
          domain = "sgp-1.dn42.nyaw.xyz";
        }
      ];
      socketFor = host: "/run/realm/vmagent/egress/observe-${host}.sock";
      identityNodes = builtins.attrNames (
        lib.filterAttrs (
          _: system: system.config.realm.spire.metrics.independent.enable or false
        ) self.nixosConfigurations
      );
      observed =
        name: endpoint: extra:
        let
          hosts = builtins.filter (
            host: self.nixosConfigurations.${host}.config.realm.observability.endpoints ? ${endpoint}
          ) (builtins.attrNames config.data.node);
        in
        {
          job_name = name;
          scheme = "http";
          metrics_path = "/${endpoint}/metrics";
          scrape_timeout = "10s";
          max_scrape_size = "32MB";
          sample_limit = 200000;
          label_limit = 100;
          follow_redirects = false;
          static_configs = map (host: {
            targets = [ host ];
            labels = {
              instance = host;
              __unix_socket__ = socketFor host;
            };
          }) hosts;
        }
        // extra;
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
          replacement = "observability";
        }
        {
          target_label = "__metrics_path__";
          replacement =
            if replacement == "10.255.0.1:9115" then "/sept-blackbox/probe" else "/blackbox/probe";
        }
        {
          target_label = "__unix_socket__";
          replacement = socketFor config.networking.hostName;
        }
      ];
      probeRules = [
        {
          module = "http_2xx";
          target = "https://nyaw.xyz";
        }
        {
          module = "http_2xx";
          target = "https://blog.nyaw.xyz";
        }
        {
          module = "http_2xx";
          target = "https://abhoth.nyaw.xyz";
        }
      ]
      ++ map (node: {
        module = "autopeer_challenge_${node.name}";
        target = autopeer_challenge_url;
      }) autopeer_nodes
      ++
        map
          (target: {
            module = "tcp_connect";
            inherit target;
          })
          [
            "[2001:4860:4860::8888]:53"
            "www.bilibili.com:80"
            "www.baidu.com:80"
          ]
      ++
        map
          (target: {
            module = "icmp";
            inherit target;
          })
          (
            [
              "8.8.8.8"
              "2001:4860:4860::8888"
              "223.6.6.6"
            ]
            ++ lib.concatMap (entry: entry.targets) config.fn.targetsFromNodes
          )
      ++ lib.optional (config.networking.hostName == "eihort") {
        module = "http_with_proxy_to_ext";
        target = "http://connectivitycheck.gstatic.com/generate_204";
      };

    in
    {
      realm.workloads.vmagent = {
        runtime = "external";
        isolation.privateNetwork = false;
        egress = lib.genAttrs (map (host: "observe-${host}") (builtins.attrNames config.data.node)) (
          name:
          let
            host = lib.removePrefix "observe-" name;
          in
          {
            service = "observability-${host}";
          }
        );
      };
      realm.observability.endpoints = {
        vmagent.port = 8429;
        vmalert.port = 8880;
        alertmanager.port = 9093;
        victoriametrics = {
          port = 19090;
          publicProxyPort = 9090;
          # Grafana queries the full API through an authenticated listener; the
          # plaintext business port stays available to the existing mesh clients.
          businessProxyPort = 19091;
          businessAllowedIDs = [ "spiffe://nyaw.xyz/service/grafana" ];
        };
      };
      realm.observability.endpoints.blackbox = {
        port = config.services.prometheus.exporters.blackbox.port;
        path = "/probe";
        kind = "probe";
        probes = probeRules;
      };
      vaultix.secrets = {
        notifychan = {
          owner = "root";
          mode = "400";
        };
        prom = {
          owner = "vmagent";
          mode = "400";
        };
        syncthing-hastur-api = {
          owner = "vmagent";
          mode = "400";
        };
      };

      systemd.services = {
        alertmanager.serviceConfig.LoadCredential = [
          "notifychan:${config.vaultix.secrets.notifychan.path}"
        ];
        vmagent.serviceConfig.LoadCredential = (map (config.fn.genCredPath)) [
          "prom"
          "syncthing-hastur-api"
        ];
      };

      services.victoriametrics = {
        enable = true;
        listenAddress = "127.0.0.1:19090";
        extraOptions = [
          "-enableTCP6"
          "-dedup.minScrapeInterval=10s"
        ];
        retentionPeriod = "60d";
      };
      services.vmagent = {
        enable = true;
        extraArgs = [
          "-httpListenAddr=127.0.0.1:8429"
          "-remoteWrite.maxDiskUsagePerURL=1GB"
          "-remoteWrite.queues=2"
          "-remoteWrite.url=${
            if config.networking.hostName == "hastur" then "http://127.0.0.1:19090" else "http://[fdcc::1]:9090"
          }/api/v1/write"
          "-remoteWrite.url=${
            if config.networking.hostName == "eihort" then "http://127.0.0.1:19090" else "http://[fdcc::3]:9090"
          }/api/v1/write"
          "-remoteWrite.url=${
            if config.networking.hostName == "uubboo" then "http://127.0.0.1:19090" else "http://[fdcc::6]:9090"
          }/api/v1/write"
          "-enableTCP6"
          "-remoteWrite.tmpDataPath=/var/cache/vmagent"
        ];

        prometheusConfig = {
          scrape_configs =
            let
              secPath = "/run/credentials/vmagent.service/prom";
            in
            [
              (observed "vmagent" "vmagent" { })
              (observed "vmalert" "vmalert" { })
              (observed "alertmanager" "alertmanager" { })
              (observed "victoriametrics" "victoriametrics" { })
              (observed "caddy" "caddy" { })
              (observed "envoy" "envoy" { })
              (observed "spire-agent" "spire-agent" { })
              (observed "spire-server" "spire-server" { })
              (observed "identity-spiffe" "identity" { })
              (observed "attestation-agent" "attestation-agent" {
                metric_relabel_configs = [
                  {
                    source_labels = [ "node" ];
                    regex = "([^.]+)\\.nyaw\\.xyz";
                    target_label = "node";
                    replacement = "$1";
                  }
                ];
              })
              (observed "attestation-server" "attestation-server" { })
              (observed "attestation-responder" "attestation-responder" {
                metric_relabel_configs = [
                  {
                    source_labels = [ "node" ];
                    regex = "([^.]+)\\.nyaw\\.xyz";
                    target_label = "node";
                    replacement = "$1";
                  }
                ];
              })
              {
                job_name = "realm-identity";
                scrape_interval = "30s";
                scrape_timeout = "10s";
                static_configs = map (host: {
                  targets = [
                    "${self.nixosConfigurations.${host}.config.realm.spire.metrics.independent.address}:${
                      toString self.nixosConfigurations.${host}.config.realm.spire.metrics.independent.port
                    }"
                  ];
                  labels = {
                    instance = host;
                    transport = "wireguard";
                  };
                }) identityNodes;
              }
              (observed "metrics" "node" { })
              (observed "ncps" "ncps" { })
              (observed "minecraft_metrics" "mc" { })
              (observed "tg-online" "tg-online" { })
              (observed "seaweedfs_metrics" "seaweedfs" { })
              (observed "centre_psql_metrics" "postgres" { })
              (observed "ntfy_metrics" "ntfy" { })
              (observed "synapse_metrics" "synapse" { })
              (observed "wgmesh_metrics" "wgmesh" { })
              (observed "bird_metrics" "bird" { })
              (observed "chrony_metrics" "chrony" {
                scrape_interval = "60s";
                scrape_timeout = "20s";
              })
              (observed "syncthing_metrics" "syncthing" {
                authorization.credentials_file = "/run/credentials/vmagent.service/syncthing-hastur-api";
              })
              (observed "garage_metrics" "garage" { })
              (observed "eihort_cf_tunnel_metrics" "cloudflared" { })
              (observed "stalwart_metrics" "stalwart" {
                basic_auth = {
                  username = "stalwart_metric";
                  password_file = secPath;
                };
                metric_relabel_configs = [
                  {
                    source_labels = [ "__name__" ];
                    regex = "(.*)";
                    target_label = "__name__";
                    replacement = "stalwart_$1";
                    action = "replace";
                  }
                ];
              })
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
                      "abhoth"
                    ];
                  }
                ];
                relabel_configs = gen_relabel_configs (
                  with config.services.prometheus.exporters.blackbox; "${listenAddress}:${toString port}"
                );
              }

              {
                job_name = "dn42-autopeer-challenge";
                scheme = "http";
                metrics_path = "/probe";
                scrape_interval = "10m";
                scrape_timeout = "15s";
                static_configs = map (node: {
                  targets = [ autopeer_challenge_url ];
                  labels = {
                    node = node.name;
                    backend = node.domain;
                    monitor = config.networking.hostName;
                    probe_module = "autopeer_challenge_${node.name}";
                  };
                }) autopeer_nodes;
                relabel_configs =
                  gen_relabel_configs (
                    with config.services.prometheus.exporters.blackbox; "${listenAddress}:${toString port}"
                  )
                  ++ [
                    {
                      source_labels = [ "probe_module" ];
                      target_label = "__param_module";
                    }
                    {
                      source_labels = [ "backend" ];
                      target_label = "instance";
                    }
                    {
                      action = "labeldrop";
                      regex = "probe_module";
                    }
                  ];
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
                      "www.bilibili.com:80"
                      "www.baidu.com:80"
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
                ]
                ++ config.fn.targetsFromNodes;
                relabel_configs = gen_relabel_configs (
                  with config.services.prometheus.exporters.blackbox; "${listenAddress}:${toString port}"
                );
              }

            ]
            ++ lib.optionals (config.networking.hostName == "eihort") [
              {
                job_name = "ping-bridge";
                scheme = "http";
                metrics_path = "/probe";
                params = {
                  module = [ "icmp" ];
                };
                static_configs = [
                  {
                    targets = [ "10.10.10.2" ];
                    labels = {
                      name = "BREAD";
                      code = "MSP";
                      ip = "IPv4";
                    };
                  }
                ];
                relabel_configs = gen_relabel_configs "10.255.0.1:9115";
              }
              {
                job_name = "metrics-sept";
                scheme = "http";
                static_configs = [
                  {
                    targets = [ "sept" ];
                    labels.__unix_socket__ = socketFor "eihort";
                  }
                ];
                metrics_path = "/sept-node/metrics";
                relabel_configs = [
                  {
                    target_label = "job";
                    replacement = "metrics";
                  }
                  {
                    source_labels = [ "__address__" ];
                    regex = "\\[fec0::1\\]:9100";
                    target_label = "instance";
                    replacement = "sept";
                  }
                ];
              }
              {
                job_name = "sept-wg-stat";
                scheme = "http";
                static_configs = [
                  {
                    targets = [ "sept" ];
                    labels.__unix_socket__ = socketFor "eihort";
                  }
                ];
                metrics_path = "/sept-wg/metrics";
              }
              {
                job_name = "bridge_alive";
                scheme = "http";
                metrics_path = "/probe";
                params = {
                  module = [ "http_with_proxy_to_ext" ];
                };
                static_configs = [
                  {
                    targets = [
                      "http://connectivitycheck.gstatic.com/generate_204"
                    ];
                  }
                ];
                relabel_configs = gen_relabel_configs (
                  with config.services.prometheus.exporters.blackbox; "${listenAddress}:${toString port}"
                );
              }
            ];
        };
      };
      services.vmalert.instances.main = {
        enable = true;
        settings = {
          "notifier.url" =
            let
              cfg = config.services.prometheus;
            in
            [ "http://${cfg.alertmanager.listenAddress}:${toString cfg.alertmanager.port}" ];
          "httpListenAddr" = "127.0.0.1:8880";
          "datasource.url" = "http://127.0.0.1:19090";
          "remoteWrite.url" = "http://127.0.0.1:19090";
          "enableTCP6" = true;
        };

        rules = {
          groups = [
            {
              name = "metrics";
              rules = [
                {
                  alert = "OOM";
                  expr = "node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.1";
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
                  expr = "sum(rate(node_btrfs_device_errors_total[2m])) > 0";
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
            {
              name = "autopeer_health";
              rules = [
                {
                  alert = "AutopeerChallengeFailed";
                  expr = ''
                    last_over_time(probe_success{job="dn42-autopeer-challenge"}[15m]) == 0
                    or last_over_time(up{job="dn42-autopeer-challenge"}[15m]) == 0
                  '';
                  for = "20m";
                  labels.severity = "critical";
                  annotations = {
                    summary = "Autopeer challenge probe failed on {{ $labels.node }}";
                    description = "Probe source: {{ $labels.monitor }}. Target: {{ $labels.backend }}. Check the exporter, Worker routing, TLS, and database connectivity.";
                  };
                }
              ];
            }
            {
              name = "envoy";
              rules = [
                {
                  alert = "EnvoyDown";
                  expr = ''up{job="envoy"} == 0'';
                  for = "2m";
                  labels.severity = "critical";
                  annotations = {
                    summary = "Envoy egress gateway down on {{ $labels.instance }}";
                  };
                }
                {
                  alert = "EnvoyHighErrorRate";
                  expr = ''
                    sum by (instance) (rate(envoy_http_downstream_rq_xx{job="envoy",envoy_http_conn_manager_prefix="internet",envoy_response_code_class="5"}[5m]))
                    / (sum by (instance) (rate(envoy_http_downstream_rq_completed{job="envoy",envoy_http_conn_manager_prefix="internet"}[5m])) > 0) * 100 > 5
                  '';
                  for = "5m";
                  labels.severity = "warning";
                  annotations = {
                    summary = "Envoy 5xx error rate > 5% on {{ $labels.instance }}";
                  };
                }
              ];
            }
            {
              name = "realm_observability";
              rules = [
                {
                  # A monitoring host whose Workload API is unavailable stops
                  # scraping almost entirely: each egress adapter waits for an
                  # SVID, the targets time out, and the scrape counter hardly
                  # moves. A failure-rate alert therefore stays quiet, and so does
                  # systemd, because an Agent without an enrollment is skipped
                  # rather than failed.
                  #
                  # Every target here is scraped at least twice per 30 minutes
                  # (the slowest interval is 10m for the autopeer probes), while a
                  # healthy host reaches roughly twenty. Three times the target
                  # count separates the two, and only the adapter-free self-scrape
                  # keeps counting after a stall.
                  alert = "RealmScraperStalled";
                  expr = ''
                    sum by (instance) (increase(vm_promscrape_scrapes_total[30m]))
                      < sum by (instance) (vm_promscrape_targets) * 3
                  '';
                  for = "15m";
                  labels.severity = "critical";
                  annotations = {
                    summary = "scraping through the realm gateway has stalled on {{ $labels.instance }}";
                    description = "Check `systemctl status spire-agent` and that /var/lib/realm-spire/trust-bundle.pem exists on {{ $labels.instance }}, then the egress adapters in `journalctl -u realm-egress-...`. An unenrolled Agent is skipped silently, which leaves every adapter without an SVID.";
                  };
                }
              ];
            }
            {
              name = "pier_health";
              rules = [
                {
                  alert = "PierDown";
                  annotations = {
                    summary = "bridge node offline";
                  };
                  expr = ''up{job="metrics",instance="eihort"} == 0'';
                  for = "1m";
                  labels = {
                    severity = "critical";
                  };
                }
              ];
            }
          ]
          ++ import ../lib/realm/identity-alerts.nix { nodes = identityNodes; };
        };
      };
      services.prometheus = {
        exporters = {
          blackbox = {
            enable = true;
            listenAddress = "127.0.0.1";
            configFile = (pkgs.formats.yaml { }).generate "config.yml" {
              modules = {
                http_2xx = {
                  prober = "http";
                  http.follow_redirects = false;
                };
                http_with_proxy_to_ext = {
                  prober = "http";
                  http = {
                    follow_redirects = false;
                    proxy_url = "http://10.255.0.1:8080";
                    skip_resolve_phase_with_proxy = true;
                    valid_status_codes = [ 204 ];
                  };
                };
                icmp = {
                  prober = "icmp";
                };
                tcp_connect = {
                  prober = "tcp";
                  timeout = "5s";
                };
              }
              // builtins.listToAttrs (
                map (node: {
                  name = "autopeer_challenge_${node.name}";
                  value = {
                    prober = "http";
                    timeout = "10s";
                    http = {
                      method = "POST";
                      body = builtins.toJSON { asn = 4242420291; };
                      headers = {
                        "Content-Type" = "application/json";
                        "X-Backend-Target" = node.domain;
                      };
                      valid_status_codes = [ 201 ];
                      follow_redirects = false;
                      fail_if_body_not_matches_regexp = [
                        ''"nonce"[[:space:]]*:[[:space:]]*"[^"]+"''
                        ''"expires_at"[[:space:]]*:[[:space:]]*[1-9][0-9]*''
                      ];
                      fail_if_header_not_matches = [
                        {
                          header = "Content-Type";
                          regexp = "(?i)^application/json([[:space:]]*;.*)?$";
                        }
                      ];
                    };
                  };
                }) autopeer_nodes
              );
            };
          };
        };
        alertmanager =
          let
            localId = config.data.node.${config.networking.hostName}.id;
            localAddr = "[fdcc::${toString (localId + 1)}]";
          in
          {
            enable = true;
            webExternalUrl = "https://alert.nyaw.xyz";
            listenAddress = "127.0.0.1";
            port = 9093;
            logLevel = "info";
            extraFlags = [
              ''--cluster.listen-address="${localAddr}:9094"''
            ];
            clusterPeers = (
              map (i: "[fdcc::${toString i}]") (
                builtins.filter (n: n != localId + 1) [
                  1
                  3
                  6
                ]
              )
            );
            configuration = {
              global = {
                resolve_timeout = "2m";
              };
              receivers = [
                {
                  name = "telegram";
                  telegram_configs = [
                    {
                      bot_token_file = "/run/credentials/alertmanager.service/notifychan";
                      chat_id = -1002215131569;
                    }
                  ];
                }
                {
                  name = "bridge-channel";
                  telegram_configs = [
                    {
                      bot_token_file = "/run/credentials/alertmanager.service/notifychan";
                      chat_id = -1003020363451;
                    }
                  ];
                }
              ];
              route = {
                receiver = "telegram";
                group_wait = "30s";
                group_interval = "2m";
                repeat_interval = "10m";
                routes = [
                  {
                    matchers = [ "alertname = \"PierDown\"" ];
                    receiver = "bridge-channel";
                    group_wait = "30s";
                    group_interval = "2m";
                    repeat_interval = "60m";
                    continue = false;
                  }
                ];
              };
            };
          };
      };
    };
}
