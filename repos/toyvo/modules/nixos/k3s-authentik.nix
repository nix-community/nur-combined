{
  config,
  lib,
  ...
}:
let
  cfg = config.nixcfg.k3sAuthentik;

  # Pinned at nixpkgs parity (verified 2026-11-16, Task 1).
  serverImage = "ghcr.io/goauthentik/server:2026.5.6";
  ldapImage = "ghcr.io/goauthentik/ldap:2026.5.6";
  redisImage = "redis:8.10.3";

  serverPort = 9000;
  redisPort = 6379;
  # Jellyfin's LDAPS target today (10.200.0.16:6636) moves here.
  ldapPort = 6636;
  ldapNodePort = 30636;

  # Host Postgres stays put (no PG migration by design). Pods reach it
  # over the LAN (same as the DS reaching nextcloud.diekvoss.net);
  # 10.1.0.0/16 scram is already in pg_hba (nas config).
  dbHost = "10.1.0.3";
  dbPort = 5432;

  # Run as the NixOS UID (ids.uids.authentik = 362): POOL seeds are
  # already 362-owned, zero chown, and the systemd units prove the
  # binaries are happy non-root. (Image default is 1000 — deliberately
  # not used.)
  appUser = 362;

  secretName = "authentik-secrets";

  # Env shared by server/worker/beat (1:1 with containers/authentik.nix).
  # Bootstrap password intentionally absent: single-use, already consumed
  # (value stays in sops for a hypothetical from-scratch rebuild).
  dbEnv = [
    {
      name = "AUTHENTIK_POSTGRESQL__HOST";
      value = dbHost;
    }
    {
      name = "AUTHENTIK_POSTGRESQL__PORT";
      value = toString dbPort;
    }
    {
      name = "AUTHENTIK_POSTGRESQL__NAME";
      value = "authentik";
    }
    {
      name = "AUTHENTIK_POSTGRESQL__USER";
      value = "authentik";
    }
    {
      name = "AUTHENTIK_POSTGRESQL__SSLMODE";
      value = "prefer";
    }
    {
      name = "AUTHENTIK_POSTGRESQL__PASSWORD";
      valueFrom.secretKeyRef = {
        name = secretName;
        key = "db-password";
      };
    }
    {
      name = "AUTHENTIK_REDIS__HOST";
      value = "authentik-redis";
    }
    {
      name = "AUTHENTIK_REDIS__PORT";
      value = toString redisPort;
    }
    {
      name = "AUTHENTIK_SECRET_KEY";
      valueFrom.secretKeyRef = {
        name = secretName;
        key = "secret-key";
      };
    }
  ];

  nodeAffinity = {
    requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms = [
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
  };
in
{
  options.nixcfg.k3sAuthentik = {
    enable = lib.mkEnableOption "Authentik SSO (server + worker + beat + LDAP outpost + redis) in k3s";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
        message = "nixcfg.k3sAuthentik: manifests must live on a server (nas), never an agent.";
      }
    ];

    services.k3s.manifests = {
      # No file PVCs by design: all POOL/container file state read 0
      # (media/templates/certs/data are empty — the instance uses
      # defaults, and the real state lives in host Postgres). The
      # upstream default paths (/media, /templates) stay ephemeral;
      # persistence gets added if an admin ever customizes (documented).
      # Only redis keeps a PVC (sessions survive routine restarts).
      "authentik-redis-pvc.yaml".content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "authentik-redis";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          resources.requests.storage = "5Gi";
        };
      };
      "authentik-server.yaml".content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "authentik-server";
          labels.app = "authentik-server";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "authentik-server";
          template = {
            metadata.labels.app = "authentik-server";
            spec = {
              affinity.nodeAffinity = nodeAffinity;
              securityContext = {
                runAsUser = appUser;
                runAsGroup = appUser;
                fsGroup = appUser;
              };
              containers = [
                {
                  name = "server";
                  image = serverImage;
                  imagePullPolicy = "IfNotPresent";
                  args = [ "server" ];
                  # NO workingDir: the image relies on CWD=/ so that
                  # `python -m lifecycle.*` resolves the /lifecycle package
                  # (CWD is on sys.path). Overriding it breaks imports.
                  env = dbEnv;
                  ports = [ { containerPort = serverPort; } ];
                  # First boot replays migrations + blueprints against the
                  # live DB (fast — same version — but don't probe through
                  # it). Real endpoints, not fake 200s.
                  readinessProbe = {
                    httpGet = {
                      path = "/-/health/ready/";
                      port = serverPort;
                    };
                    initialDelaySeconds = 120;
                    periodSeconds = 30;
                  };
                  livenessProbe = {
                    httpGet = {
                      path = "/-/health/live/";
                      port = serverPort;
                    };
                    initialDelaySeconds = 180;
                    periodSeconds = 60;
                  };
                  # No volume mounts (see PVC note above).
                }
              ];
            };
          };
        };
      };
      "authentik-worker.yaml".content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "authentik-worker";
          labels.app = "authentik-worker";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "authentik-worker";
          template = {
            metadata.labels.app = "authentik-worker";
            spec = {
              affinity.nodeAffinity = nodeAffinity;
              securityContext = {
                runAsUser = appUser;
                runAsGroup = appUser;
                fsGroup = appUser;
              };
              # Worker + beat sidecar (matches the two NixOS units; they
              # share nothing but config).
              containers = [
                {
                  name = "worker";
                  image = serverImage;
                  imagePullPolicy = "IfNotPresent";
                  args = [ "worker" ];
                  env = dbEnv;
                  # No HTTP surface by design (upstream ships no worker
                  # health endpoint) — a bad probe is worse than none.
                  # Process exit restarts the container (restartPolicy).
                  # No volume mounts (see PVC note above).
                }
                {
                  name = "beat";
                  image = serverImage;
                  imagePullPolicy = "IfNotPresent";
                  args = [ "beat" ];
                  env = dbEnv;
                  # No volume mounts (see PVC note above).
                }
              ];
            };
          };
        };
      };
      "authentik-ldap.yaml".content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "authentik-ldap";
          labels.app = "authentik-ldap";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "authentik-ldap";
          template = {
            metadata.labels.app = "authentik-ldap";
            spec = {
              affinity.nodeAffinity = nodeAffinity;
              securityContext = {
                runAsUser = appUser;
                runAsGroup = appUser;
                fsGroup = appUser;
              };
              containers = [
                {
                  name = "ldap";
                  image = ldapImage;
                  imagePullPolicy = "IfNotPresent";
                  env = [
                    {
                      name = "AUTHENTIK_HOST";
                      value = "http://authentik:${toString serverPort}";
                    }
                    {
                      name = "AUTHENTIK_TOKEN";
                      valueFrom.secretKeyRef = {
                        name = secretName;
                        key = "ldap-token";
                      };
                    }
                  ];
                  ports = [ { containerPort = ldapPort; } ];
                  readinessProbe = {
                    tcpSocket.port = ldapPort;
                    initialDelaySeconds = 60;
                    periodSeconds = 30;
                  };
                  livenessProbe = {
                    tcpSocket.port = ldapPort;
                    initialDelaySeconds = 120;
                    periodSeconds = 60;
                  };
                }
              ];
            };
          };
        };
      };
      # Raw LDAPS for Jellyfin (Traefik can't do it without TCP route
      # config; NodePort keeps it off the edge — monitoring precedent).
      "authentik-ldap-nodeport.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "authentik-ldap";
        };
        spec = {
          type = "NodePort";
          selector.app = "authentik-ldap";
          ports = [
            {
              port = ldapPort;
              targetPort = ldapPort;
              nodePort = ldapNodePort;
            }
          ];
        };
      };
      "authentik-redis.yaml".content = {
        apiVersion = "apps/v1";
        kind = "StatefulSet";
        metadata = {
          name = "authentik-redis";
          labels.app = "authentik-redis";
        };
        spec = {
          serviceName = "authentik-redis";
          replicas = 1;
          selector.matchLabels.app = "authentik-redis";
          template = {
            metadata.labels.app = "authentik-redis";
            spec = {
              affinity.nodeAffinity = nodeAffinity;
              containers = [
                {
                  name = "redis";
                  image = redisImage;
                  imagePullPolicy = "IfNotPresent";
                  # No custom args by design: upstream defaults match the
                  # NixOS redis (no appendonly). NB: YAML 1.1 parses bare
                  # `yes` as boolean true — never pass yes/no words as
                  # separate args (k3s applier rejects them).
                  ports = [ { containerPort = redisPort; } ];
                  readinessProbe = {
                    # redis image is distroless-adjacent; TCP check only.
                    tcpSocket.port = redisPort;
                    initialDelaySeconds = 30;
                    periodSeconds = 10;
                  };
                  volumeMounts = [
                    {
                      name = "data";
                      mountPath = "/data";
                    }
                  ];
                }
              ];
            };
          };
          volumeClaimTemplates = [
            {
              metadata.name = "data";
              spec = {
                accessModes = [ "ReadWriteOnce" ];
                resources.requests.storage = "5Gi";
              };
            }
          ];
        };
      };
      "authentik-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "authentik";
        };
        spec = {
          selector.app = "authentik-server";
          ports = [
            {
              port = serverPort;
              targetPort = serverPort;
            }
          ];
        };
      };
      "authentik-redis-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "authentik-redis";
        };
        spec = {
          selector.app = "authentik-redis";
          ports = [
            {
              port = redisPort;
              targetPort = redisPort;
            }
          ];
        };
      };
    };
  };
}
