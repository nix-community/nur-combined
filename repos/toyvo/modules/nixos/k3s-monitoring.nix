{
  config,
  lib,
  homelab,
  ...
}:
let
  cfg = config.nixcfg.k3sMonitoring;
  middlewaresLib = import ./k3s-traefik-middlewares.nix { inherit lib; };

  # Pinned at nixpkgs parity (hub-verified 200 on 2026-11-16, Task 1).
  # NOTE: nixpkgs `loki` is an unrelated 0.1.7 package — the service uses
  # `grafana-loki` (3.7.9).
  grafanaImage = "grafana/grafana:13.3.0";
  prometheusImage = "prom/prometheus:v3.16.0";
  lokiImage = "grafana/loki:3.7.9";
  tempoImage = "grafana/tempo:3.1.1";

  grafanaPort = 3000;
  prometheusPort = 9090;
  lokiPort = 3100;
  tempoHttpPort = 3200;
  tempoGrpcPort = 4317;
  tempoOtlpHttpPort = 4318;

  # Agent ingest rides NodePorts on nas (keeps scrape/push traffic off
  # Traefik; no TCP route config needed).
  nodePorts = {
    prometheus = 30901;
    loki = 30902;
    tempoHttp = 30903;
    tempoGrpc = 30904;
    tempoOtlpHttp = 30905;
  };

  # 1:1 translation of the NixOS service settings in
  # containers/monitoring.nix (no behavior change by design).
  prometheusYaml = ''
    global:
      scrape_interval: 1m
      evaluation_interval: 1m
    scrape_configs:
      - job_name: prometheus
        static_configs:
          - targets:
              - localhost:${toString prometheusPort}
  '';

  lokiYaml = ''
    auth_enabled: false
    server:
      http_listen_address: 127.0.0.1
      http_listen_port: ${toString lokiPort}
    common:
      ring:
        instance_addr: 127.0.0.1
        kvstore:
          store: inmemory
      replication_factor: 1
      path_prefix: /var/lib/loki
    schema_config:
      configs:
        - from: "2024-01-01"
          store: tsdb
          object_store: filesystem
          schema: v13
          index:
            prefix: index_
            period: 24h
    storage_config:
      filesystem:
        directory: /var/lib/loki/chunks
    limits_config:
      retention_period: 336h
      allow_structured_metadata: false
    compactor:
      working_directory: /var/lib/loki/compactor
      compaction_interval: 10m
      retention_enabled: true
      delete_request_cancel_period: 10m
      retention_delete_delay: 2h
      delete_request_store: filesystem
  '';

  tempoYaml = ''
    server:
      http_listen_address: 0.0.0.0
      http_listen_port: ${toString tempoHttpPort}
      grpc_listen_port: 9096
    distributor:
      receivers:
        otlp:
          protocols:
            grpc:
              endpoint: 0.0.0.0:${toString tempoGrpcPort}
            http:
              endpoint: 0.0.0.0:${toString tempoOtlpHttpPort}
    storage:
      trace:
        backend: local
        local:
          path: /var/lib/tempo/traces
        wal:
          path: /var/lib/tempo/wal
    compactor:
      compaction:
        block_retention: 336h
    metrics_generator:
      registry:
        external_labels:
          source: tempo
      storage:
        path: /var/lib/tempo/generator/wal
        remote_write:
          - url: http://prometheus:${toString prometheusPort}/api/v1/write
  '';

  grafanaIni = ''
    [server]
    http_addr = 0.0.0.0
    http_port = ${toString grafanaPort}
    domain = grafana.diekvoss.net
    root_url = https://grafana.diekvoss.net/
    [security]
    admin_user = admin
    admin_password = $__file{/run/secrets/admin-password}
    secret_key = $__file{/run/secrets/secret-key}
    [paths]
    provisioning = /etc/grafana/provisioning
  '';

  datasourcesYaml = ''
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        access: proxy
        url: http://prometheus:${toString prometheusPort}
        isDefault: true
      - name: Loki
        type: loki
        access: proxy
        url: http://loki:${toString lokiPort}
      - name: Tempo
        type: tempo
        access: proxy
        url: http://tempo:${toString tempoHttpPort}
  '';

  dashboardsYaml = ''
    apiVersion: 1
    providers:
      - name: homelab
        options:
          path: /etc/grafana/dashboards
        disableDeletion: true
        updateIntervalSeconds: 300
  '';
in
{
  options.nixcfg.k3sMonitoring = {
    enable = lib.mkEnableOption "Monitoring stack (Grafana + Prometheus + Loki + Tempo) in k3s";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
        message = "nixcfg.k3sMonitoring: manifests must live on a server (nas), never an agent.";
      }
    ];

    services.k3s.manifests = {
      # Grafana sqlite lives on a standalone PVC (Deployments can't use
      # volumeClaimTemplates).
      "monitoring-grafana-pvc.yaml".content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "monitoring-grafana";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          resources.requests.storage = "5Gi";
        };
      };
      "monitoring-grafana-config.yaml".content = {
        apiVersion = "v1";
        kind = "ConfigMap";
        metadata = {
          name = "monitoring-grafana-config";
        };
        data = {
          "grafana.ini" = grafanaIni;
          "provisioning/datasources/datasources.yaml" = datasourcesYaml;
          "provisioning/dashboards/dashboards.yaml" = dashboardsYaml;
        };
      };
      # 28K of dashboards ride a ConfigMap (same files the container
      # bind-mounted from the repo).
      "monitoring-grafana-dashboards.yaml".content = {
        apiVersion = "v1";
        kind = "ConfigMap";
        metadata = {
          name = "monitoring-grafana-dashboards";
        };
        data = {
          "dns-security.json" = builtins.readFile ./containers/dashboards/dns-security.json;
          "internet.json" = builtins.readFile ./containers/dashboards/internet.json;
          "network-inventory.json" = builtins.readFile ./containers/dashboards/network-inventory.json;
        };
      };
      "monitoring-grafana.yaml".content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "monitoring-grafana";
          labels.app = "monitoring-grafana";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "monitoring-grafana";
          template = {
            metadata.labels.app = "monitoring-grafana";
            spec = {
              affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms = [
                {
                  matchExpressions = [
                    {
                      key = "kubernetes.io/hostname";
                      operator = "In";
                      values = [ "nas" ];
                    }
                  ];
                }
              ];
              securityContext = {
                runAsUser = 472;
                runAsGroup = 472;
                fsGroup = 472;
              };
              containers = [
                {
                  name = "grafana";
                  image = grafanaImage;
                  imagePullPolicy = "IfNotPresent";
                  ports = [ { containerPort = grafanaPort; } ];
                  readinessProbe = {
                    httpGet = {
                      path = "/api/health";
                      port = grafanaPort;
                    };
                    initialDelaySeconds = 60;
                    periodSeconds = 30;
                  };
                  livenessProbe = {
                    httpGet = {
                      path = "/api/health";
                      port = grafanaPort;
                    };
                    initialDelaySeconds = 120;
                    periodSeconds = 60;
                  };
                  volumeMounts = [
                    {
                      name = "data";
                      mountPath = "/var/lib/grafana";
                    }
                    {
                      name = "config";
                      mountPath = "/etc/grafana/grafana.ini";
                      subPath = "grafana.ini";
                    }
                    {
                      name = "config";
                      mountPath = "/etc/grafana/provisioning/datasources/datasources.yaml";
                      subPath = "provisioning/datasources/datasources.yaml";
                    }
                    {
                      name = "config";
                      mountPath = "/etc/grafana/provisioning/dashboards/dashboards.yaml";
                      subPath = "provisioning/dashboards/dashboards.yaml";
                    }
                    {
                      name = "dashboards";
                      mountPath = "/etc/grafana/dashboards";
                      readOnly = true;
                    }
                    {
                      name = "secrets";
                      mountPath = "/run/secrets";
                      readOnly = true;
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "data";
                  persistentVolumeClaim.claimName = "monitoring-grafana";
                }
                {
                  name = "config";
                  configMap.name = "monitoring-grafana-config";
                }
                {
                  name = "dashboards";
                  configMap.name = "monitoring-grafana-dashboards";
                }
                {
                  name = "secrets";
                  secret.secretName = "monitoring-grafana";
                }
              ];
            };
          };
        };
      };
      "monitoring-grafana-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "grafana";
        };
        spec = {
          selector.app = "monitoring-grafana";
          ports = [
            {
              port = grafanaPort;
              targetPort = grafanaPort;
            }
          ];
        };
      };
      "monitoring-prometheus.yaml".content = {
        apiVersion = "apps/v1";
        kind = "StatefulSet";
        metadata = {
          name = "monitoring-prometheus";
          labels.app = "monitoring-prometheus";
        };
        spec = {
          serviceName = "prometheus";
          replicas = 1;
          selector.matchLabels.app = "monitoring-prometheus";
          template = {
            metadata.labels.app = "monitoring-prometheus";
            spec = {
              affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms = [
                {
                  matchExpressions = [
                    {
                      key = "kubernetes.io/hostname";
                      operator = "In";
                      values = [ "nas" ];
                    }
                  ];
                }
              ];
              securityContext = {
                runAsUser = 65534;
                runAsGroup = 65534;
                fsGroup = 65534;
              };
              containers = [
                {
                  name = "prometheus";
                  image = prometheusImage;
                  imagePullPolicy = "IfNotPresent";
                  args = [
                    "--config.file=/etc/prometheus/prometheus.yml"
                    "--storage.tsdb.path=/var/lib/prometheus"
                    "--storage.tsdb.retention.time=30d"
                    "--web.enable-remote-write-receiver"
                    "--web.enable-admin-api"
                    "--web.listen-address=0.0.0.0:${toString prometheusPort}"
                  ];
                  ports = [ { containerPort = prometheusPort; } ];
                  # Cold TSDB load (WAL replay + block open) takes minutes
                  # on a 30d retention — don't SIGKILL mid-load (office
                  # lesson: initial delays or crashloop forever).
                  readinessProbe = {
                    httpGet = {
                      path = "/-/ready";
                      port = prometheusPort;
                    };
                    initialDelaySeconds = 120;
                    periodSeconds = 30;
                  };
                  livenessProbe = {
                    httpGet = {
                      path = "/-/healthy";
                      port = prometheusPort;
                    };
                    initialDelaySeconds = 180;
                    periodSeconds = 60;
                  };
                  volumeMounts = [
                    {
                      name = "data";
                      mountPath = "/var/lib/prometheus";
                    }
                    {
                      name = "config";
                      mountPath = "/etc/prometheus/prometheus.yml";
                      subPath = "prometheus.yml";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "config";
                  configMap.name = "monitoring-prometheus-config";
                }
              ];
            };
          };
          volumeClaimTemplates = [
            {
              metadata.name = "data";
              spec = {
                accessModes = [ "ReadWriteOnce" ];
                resources.requests.storage = "50Gi";
              };
            }
          ];
        };
      };
      "monitoring-prometheus-config.yaml".content = {
        apiVersion = "v1";
        kind = "ConfigMap";
        metadata = {
          name = "monitoring-prometheus-config";
        };
        data = {
          "prometheus.yml" = prometheusYaml;
        };
      };
      "monitoring-prometheus-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "prometheus";
        };
        spec = {
          selector.app = "monitoring-prometheus";
          ports = [
            {
              port = prometheusPort;
              targetPort = prometheusPort;
            }
          ];
        };
      };
      "monitoring-prometheus-nodeport.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "prometheus-ingest";
        };
        spec = {
          type = "NodePort";
          selector.app = "monitoring-prometheus";
          ports = [
            {
              port = prometheusPort;
              targetPort = prometheusPort;
              nodePort = nodePorts.prometheus;
            }
          ];
        };
      };
      "monitoring-loki.yaml".content = {
        apiVersion = "apps/v1";
        kind = "StatefulSet";
        metadata = {
          name = "monitoring-loki";
          labels.app = "monitoring-loki";
        };
        spec = {
          serviceName = "loki";
          replicas = 1;
          selector.matchLabels.app = "monitoring-loki";
          template = {
            metadata.labels.app = "monitoring-loki";
            spec = {
              affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms = [
                {
                  matchExpressions = [
                    {
                      key = "kubernetes.io/hostname";
                      operator = "In";
                      values = [ "nas" ];
                    }
                  ];
                }
              ];
              securityContext = {
                runAsUser = 10001;
                runAsGroup = 10001;
                fsGroup = 10001;
              };
              containers = [
                {
                  name = "loki";
                  image = lokiImage;
                  imagePullPolicy = "IfNotPresent";
                  args = [
                    "-target=all"
                    "-config.file=/etc/loki/loki.yaml"
                  ];
                  ports = [ { containerPort = lokiPort; } ];
                  readinessProbe = {
                    httpGet = {
                      path = "/ready";
                      port = lokiPort;
                    };
                    initialDelaySeconds = 60;
                    periodSeconds = 30;
                  };
                  livenessProbe = {
                    httpGet = {
                      path = "/ready";
                      port = lokiPort;
                    };
                    initialDelaySeconds = 120;
                    periodSeconds = 60;
                  };
                  volumeMounts = [
                    {
                      name = "data";
                      mountPath = "/var/lib/loki";
                    }
                    {
                      name = "config";
                      mountPath = "/etc/loki/loki.yaml";
                      subPath = "loki.yaml";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "config";
                  configMap.name = "monitoring-loki-config";
                }
              ];
            };
          };
          volumeClaimTemplates = [
            {
              metadata.name = "data";
              spec = {
                accessModes = [ "ReadWriteOnce" ];
                resources.requests.storage = "50Gi";
              };
            }
          ];
        };
      };
      "monitoring-loki-config.yaml".content = {
        apiVersion = "v1";
        kind = "ConfigMap";
        metadata = {
          name = "monitoring-loki-config";
        };
        data = {
          "loki.yaml" = lokiYaml;
        };
      };
      "monitoring-loki-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "loki";
        };
        spec = {
          selector.app = "monitoring-loki";
          ports = [
            {
              port = lokiPort;
              targetPort = lokiPort;
            }
          ];
        };
      };
      # The container's nginx allowlist gateway is dropped by design: in
      # k3s the NodePort is LAN-reachable and all pushers are LAN hosts.
      "monitoring-loki-nodeport.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "loki-ingest";
        };
        spec = {
          type = "NodePort";
          selector.app = "monitoring-loki";
          ports = [
            {
              port = lokiPort;
              targetPort = lokiPort;
              nodePort = nodePorts.loki;
            }
          ];
        };
      };
      "monitoring-tempo.yaml".content = {
        apiVersion = "apps/v1";
        kind = "StatefulSet";
        metadata = {
          name = "monitoring-tempo";
          labels.app = "monitoring-tempo";
        };
        spec = {
          serviceName = "tempo";
          replicas = 1;
          selector.matchLabels.app = "monitoring-tempo";
          template = {
            metadata.labels.app = "monitoring-tempo";
            spec = {
              affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms = [
                {
                  matchExpressions = [
                    {
                      key = "kubernetes.io/hostname";
                      operator = "In";
                      values = [ "nas" ];
                    }
                  ];
                }
              ];
              securityContext = {
                runAsUser = 10001;
                runAsGroup = 10001;
                fsGroup = 10001;
              };
              containers = [
                {
                  name = "tempo";
                  image = tempoImage;
                  imagePullPolicy = "IfNotPresent";
                  args = [
                    "-config.file=/etc/tempo/tempo.yaml"
                  ];
                  ports = [
                    { containerPort = tempoHttpPort; }
                    { containerPort = tempoGrpcPort; }
                    { containerPort = tempoOtlpHttpPort; }
                  ];
                  readinessProbe = {
                    httpGet = {
                      path = "/ready";
                      port = tempoHttpPort;
                    };
                    initialDelaySeconds = 60;
                    periodSeconds = 30;
                  };
                  livenessProbe = {
                    httpGet = {
                      path = "/ready";
                      port = tempoHttpPort;
                    };
                    initialDelaySeconds = 120;
                    periodSeconds = 60;
                  };
                  volumeMounts = [
                    {
                      name = "data";
                      mountPath = "/var/lib/tempo";
                    }
                    {
                      name = "config";
                      mountPath = "/etc/tempo/tempo.yaml";
                      subPath = "tempo.yaml";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "config";
                  configMap.name = "monitoring-tempo-config";
                }
              ];
            };
          };
          volumeClaimTemplates = [
            {
              metadata.name = "data";
              spec = {
                accessModes = [ "ReadWriteOnce" ];
                resources.requests.storage = "20Gi";
              };
            }
          ];
        };
      };
      "monitoring-tempo-config.yaml".content = {
        apiVersion = "v1";
        kind = "ConfigMap";
        metadata = {
          name = "monitoring-tempo-config";
        };
        data = {
          "tempo.yaml" = tempoYaml;
        };
      };
      "monitoring-tempo-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "tempo";
        };
        spec = {
          selector.app = "monitoring-tempo";
          ports = [
            {
              name = "http";
              port = tempoHttpPort;
              targetPort = tempoHttpPort;
            }
            {
              name = "otlp-grpc";
              port = tempoGrpcPort;
              targetPort = tempoGrpcPort;
            }
            {
              name = "otlp-http";
              port = tempoOtlpHttpPort;
              targetPort = tempoOtlpHttpPort;
            }
          ];
        };
      };
      "monitoring-tempo-nodeport.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "tempo-ingest";
        };
        spec = {
          type = "NodePort";
          selector.app = "monitoring-tempo";
          ports = [
            {
              name = "http";
              port = tempoHttpPort;
              targetPort = tempoHttpPort;
              nodePort = nodePorts.tempoHttp;
            }
            {
              name = "otlp-grpc";
              port = tempoGrpcPort;
              targetPort = tempoGrpcPort;
              nodePort = nodePorts.tempoGrpc;
            }
            {
              name = "otlp-http";
              port = tempoOtlpHttpPort;
              targetPort = tempoOtlpHttpPort;
              nodePort = nodePorts.tempoOtlpHttp;
            }
          ];
        };
      };
      # Grafana UI keeps forward-auth ON (default) — same pattern as the
      # nextcloud plain Ingress. The homelab edge route for grafana is
      # removed at flip time (same host can't have two routers).
      "monitoring-grafana-ingress.yaml".content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "monitoring-grafana";
          annotations = {
            "traefik.ingress.kubernetes.io/router.middlewares" =
              middlewaresLib.ingressMiddlewareAnnotation homelab.monitoring.services.grafana;
          };
        };
        spec = {
          ingressClassName = "traefik";
          tls = [
            {
              hosts = [ "grafana.diekvoss.net" ];
              secretName = "wildcard-tls-diekvoss-net";
            }
          ];
          rules = [
            {
              host = "grafana.diekvoss.net";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "grafana";
                    port.number = grafanaPort;
                  };
                }
              ];
            }
          ];
        };
      };
    };
  };
}
