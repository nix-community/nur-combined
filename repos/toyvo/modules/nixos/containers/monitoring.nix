{
  config,
  lib,
  homelab,
  ...
}:
let
  cfg = config.containerPresets.monitoring;
in
{
  options.containerPresets.monitoring = {
    enable = lib.mkEnableOption "Monitoring stack NixOS container";

    hostAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.3";
      description = "Host side of the veth pair";
    };

    localAddress = lib.mkOption {
      type = lib.types.str;
      default = "10.200.0.4";
      description = "Container IP address";
    };

    stateDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/nixos-containers/monitoring";
      description = "Base directory containing per-service state subdirectories";
    };

    grafanaAdminPasswordFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Grafana admin password file on the host (decrypted by sops; bind-mounted read-only into the container)";
    };

    grafanaSecretKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the Grafana secret key file on the host (decrypted by sops; bind-mounted read-only into the container)";
    };

    natInterface = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Host WAN-facing interface for NAT masquerade; required when the container needs to reach external hosts (e.g. grafana.com for dashboard imports)";
    };

    ports = {
      grafana = lib.mkOption {
        type = lib.types.port;
        default = homelab.monitoring.services.grafana.port;
        description = "Grafana listen port";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.nat = lib.mkIf (cfg.natInterface != null) {
      enable = true;
      externalInterface = cfg.natInterface;
      internalInterfaces = [ "ve-monitoring" ];
    };

    containers.monitoring = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = cfg.hostAddress;
      localAddress = cfg.localAddress;

      bindMounts = {
        # Grafana credentials decrypted by sops on the host, made available read-only inside
        "/run/secrets/grafana-admin-password" = {
          hostPath = cfg.grafanaAdminPasswordFile;
          isReadOnly = true;
        };
        "/run/secrets/grafana-secret-key" = {
          hostPath = cfg.grafanaSecretKeyFile;
          isReadOnly = true;
        };
        "/var/lib/grafana" = {
          hostPath = "${cfg.stateDir}/grafana";
          isReadOnly = false;
        };
        "/var/lib/prometheus" = {
          hostPath = "${cfg.stateDir}/prometheus";
          isReadOnly = false;
        };
        "/var/lib/loki" = {
          hostPath = "${cfg.stateDir}/loki";
          isReadOnly = false;
        };
        "/var/lib/tempo" = {
          hostPath = "${cfg.stateDir}/tempo";
          isReadOnly = false;
        };
      };

      config =
        { ... }:
        {
          services.grafana = {
            enable = true;
            settings = {
              server = {
                http_addr = "0.0.0.0";
                http_port = cfg.ports.grafana;
                domain = "grafana.diekvoss.net";
                root_url = "https://grafana.diekvoss.net";
              };
              security = {
                admin_user = "admin";
                # sops secrets bind-mounted with mode 0444 so grafana user can read them
                admin_password = "$__file{/run/secrets/grafana-admin-password}";
                secret_key = "$__file{/run/secrets/grafana-secret-key}";
              };
            };
            provision = {
              enable = true;
              datasources.settings.datasources = [
                {
                  name = "Prometheus";
                  type = "prometheus";
                  url = "http://localhost:9090";
                  isDefault = true;
                  access = "proxy";
                }
                {
                  name = "Loki";
                  type = "loki";
                  # Loki's internal port — co-located so no nginx gateway needed for this datasource
                  url = "http://localhost:3101";
                  access = "proxy";
                }
                {
                  name = "Tempo";
                  type = "tempo";
                  url = "http://localhost:3200";
                  access = "proxy";
                }
              ];
            };
          };

          services.prometheus = {
            enable = true;
            port = 9090;
            retentionTime = "30d";
            extraFlags = [ "--web.enable-remote-write-receiver" ];
          };

          services.loki = {
            enable = true;
            configuration = {
              auth_enabled = false;

              server = {
                http_listen_address = "127.0.0.1";
                http_listen_port = 3101;
              };

              common = {
                ring = {
                  instance_addr = "127.0.0.1";
                  kvstore.store = "inmemory";
                };
                replication_factor = 1;
                path_prefix = "/var/lib/loki";
              };

              schema_config.configs = [
                {
                  from = "2024-01-01";
                  store = "tsdb";
                  object_store = "filesystem";
                  schema = "v13";
                  index = {
                    prefix = "index_";
                    period = "24h";
                  };
                }
              ];

              storage_config.filesystem.directory = "/var/lib/loki/chunks";

              limits_config = {
                retention_period = "336h";
                allow_structured_metadata = false;
              };

              compactor = {
                working_directory = "/var/lib/loki/compactor";
                compaction_interval = "10m";
                retention_enabled = true;
                delete_request_cancel_period = "10m";
                retention_delete_delay = "2h";
                delete_request_store = "filesystem";
              };
            };
          };

          # Nginx gateway exposes Loki on a public port with IP allowlisting.
          # 10.200.0.0/16 covers traffic from the NAS host (10.200.0.3) and other containers.
          services.nginx = {
            enable = true;
            virtualHosts."loki-gateway" = {
              listen = [
                {
                  addr = "0.0.0.0";
                  port = 3100;
                }
              ];
              locations."/" = {
                proxyPass = "http://127.0.0.1:3101";
                extraConfig = ''
                  allow 127.0.0.1;
                  allow 10.1.0.0/24;
                  allow 10.100.0.0/24;
                  allow 10.200.0.0/16;
                  deny all;

                  proxy_set_header X-Scope-OrgID $http_x_scope_orgid;
                '';
              };
            };
          };

          services.tempo = {
            enable = true;
            settings = {
              server = {
                http_listen_address = "0.0.0.0";
                http_listen_port = 3200;
                grpc_listen_port = 9096;
              };

              distributor.receivers = {
                otlp.protocols = {
                  grpc.endpoint = "0.0.0.0:4317";
                  http.endpoint = "0.0.0.0:4318";
                };
              };

              storage.trace = {
                backend = "local";
                local.path = "/var/lib/tempo/traces";
                wal.path = "/var/lib/tempo/wal";
              };

              compactor.compaction.block_retention = "336h";

              metrics_generator = {
                registry.external_labels.source = "tempo";
                storage = {
                  path = "/var/lib/tempo/generator/wal";
                  remote_write = [
                    { url = "http://localhost:9090/api/v1/write"; }
                  ];
                };
              };
            };
          };

          networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
          networking.defaultGateway = cfg.hostAddress;

          networking.firewall.allowedTCPPorts = [
            cfg.ports.grafana
            9090 # Prometheus remote-write receiver
            3100 # Loki nginx gateway
            3200 # Tempo HTTP API
            4317 # OTLP gRPC
            4318 # OTLP HTTP
          ];

          system.stateVersion = "26.05";
        };
    };
  };
}
