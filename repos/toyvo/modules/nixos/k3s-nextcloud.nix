{
  config,
  homelab,
  lib,
  ...
}:
let
  cfg = config.nixcfg.k3sNextcloud;
  middlewaresLib = import ./k3s-traefik-middlewares.nix { inherit lib; };

  # Pinned to the NixOS container's versions (pkgs.nextcloud35 35.0.2,
  # bundled PG 18.6) — no version migration involved. Tags verified
  # 2026-11-14 against the Docker Hub manifest API (both 200):
  #   nextcloud:35.0.2-apache, postgres:18-alpine.
  nextcloudImage = "nextcloud:35.0.2-apache";
  nextcloudPostgresImage = "postgres:18-alpine";
  nextcloudPort = 80;

  # Run everything as the nextcloud UID (ids.uids.nextcloud = 360, matching
  # POOL ownership + the /mnt/POOL/{Public,Collin,Chloe} ACLs) instead of
  # root or www-data: the media NFS exports use root_squash (root-in-pod
  # would be squashed to nobody), and 360 is the one UID with RW on all
  # three external-storage dirs. No fsGroup: nothing here needs group
  # chowns and the media roots must not be recursively touched.
  runAs = {
    runAsUser = 360;
    runAsGroup = 360;
  };
in
{
  options.nixcfg.k3sNextcloud = {
    enable = lib.mkEnableOption "Nextcloud in k3s (official image, UID 360, bundled Postgres + cron sidecar, Collabora dropped)";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
        message = "nixcfg.k3sNextcloud: manifests must live on a server (nas), never an agent.";
      }
    ];

    services.k3s.manifests = {
      # Postgres owns the irreplaceable state (users, filecache, mounts,
      # shares). local-path ONLY — never NFS. Seeded on cutover day via
      # pg_dumpall from the live container (99M; DB `nextcloud`, peer
      # auth there, password auth here — runbook sets the role password
      # to the secretspec value post-restore).
      "nextcloud-postgres-statefulset.yaml".content = {
        apiVersion = "apps/v1";
        kind = "StatefulSet";
        metadata = {
          name = "nextcloud-postgres";
          labels.app = "nextcloud-postgres";
        };
        spec = {
          serviceName = "nextcloud-postgres";
          replicas = 1;
          selector.matchLabels.app = "nextcloud-postgres";
          template = {
            metadata.labels.app = "nextcloud-postgres";
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
              containers = [
                {
                  name = "postgres";
                  image = nextcloudPostgresImage;
                  imagePullPolicy = "IfNotPresent";
                  env = [
                    {
                      name = "POSTGRES_USER";
                      value = "postgres";
                    }
                    {
                      name = "POSTGRES_DB";
                      value = "nextcloud";
                    }
                    {
                      name = "POSTGRES_PASSWORD";
                      valueFrom.secretKeyRef = {
                        name = "nextcloud-db";
                        key = "DB_PASSWORD";
                      };
                    }
                    {
                      name = "POSTGRES_INITDB_ARGS";
                      value = "--data-checksums";
                    }
                    {
                      name = "TZ";
                      value = "America/Chicago";
                    }
                  ];
                  ports = [ { containerPort = 5432; } ];
                  resources = {
                    requests = {
                      cpu = "100m";
                      memory = "256Mi";
                    };
                    limits = {
                      cpu = "2000m";
                      memory = "2Gi";
                    };
                  };
                  volumeMounts = [
                    {
                      name = "pgdata";
                      mountPath = "/var/lib/postgresql/data";
                    }
                  ];
                }
              ];
            };
          };
          volumeClaimTemplates = [
            {
              metadata.name = "pgdata";
              spec = {
                accessModes = [ "ReadWriteOnce" ];
                resources.requests.storage = "5Gi";
              };
            }
          ];
        };
      };
      "nextcloud-postgres-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "nextcloud-postgres";
        };
        spec = {
          selector.app = "nextcloud-postgres";
          ports = [
            {
              port = 5432;
              targetPort = 5432;
            }
          ];
        };
      };
      "nextcloud-state-pvc.yaml".content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "nextcloud-state";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          resources.requests.storage = "10Gi";
        };
      };
      # One PV per external-storage dir (PVs bind 1:1). Shares mirror the
      # verified oc_storages local mounts; Collin/Chloe need new NFS
      # exports (Public already exported).
      "nextcloud-public-pvc.yaml".content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "nextcloud-public";
        };
        spec = {
          accessModes = [ "ReadWriteMany" ];
          storageClassName = "nfs-pool";
          resources.requests.storage = "100Gi";
        };
      };
      "nextcloud-collin-pvc.yaml".content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "nextcloud-collin";
        };
        spec = {
          accessModes = [ "ReadWriteMany" ];
          storageClassName = "nfs-pool";
          resources.requests.storage = "100Gi";
        };
      };
      "nextcloud-chloe-pvc.yaml".content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "nextcloud-chloe";
        };
        spec = {
          accessModes = [ "ReadWriteMany" ];
          storageClassName = "nfs-pool";
          resources.requests.storage = "100Gi";
        };
      };
      # Replicas 1 from the start (Jellyfin precedent): no shared-state
      # hazard pre-flip (fresh empty DB + state, edge still routes to the
      # container), and manifest=1 is switch-stable.
      "nextcloud-deployment.yaml".content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "nextcloud";
          labels.app = "nextcloud";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "nextcloud";
          template = {
            metadata.labels.app = "nextcloud";
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
              containers = [
                {
                  name = "nextcloud";
                  image = nextcloudImage;
                  imagePullPolicy = "IfNotPresent";
                  securityContext = runAs;
                  env = [
                    {
                      name = "NEXTCLOUD_DATA_DIR";
                      value = "/var/lib/nextcloud";
                    }
                    {
                      name = "TZ";
                      value = "America/Chicago";
                    }
                  ];
                  ports = [ { containerPort = nextcloudPort; } ];
                  resources = {
                    requests = {
                      cpu = "200m";
                      memory = "512Mi";
                    };
                    limits = {
                      cpu = "2000m";
                      memory = "2Gi";
                    };
                  };
                  volumeMounts = [
                    {
                      name = "state";
                      mountPath = "/var/lib/nextcloud";
                    }
                    {
                      name = "custom-apps";
                      mountPath = "/var/www/html/custom_apps";
                      # Same claim as state (auto-created subdir): apps
                      # persist without a second PVC, and the store can
                      # write here as UID 360.
                      subPath = "custom_apps";
                    }
                    {
                      name = "public";
                      mountPath = "/mnt/Public";
                    }
                    {
                      name = "collin";
                      mountPath = "/mnt/Collin";
                    }
                    {
                      name = "chloe";
                      mountPath = "/mnt/Chloe";
                    }
                  ];
                }
                {
                  # No systemd timers in k8s: cron.php loop (upstream
                  # pattern), same image, same UID so state stays owned.
                  name = "nextcloud-cron";
                  image = nextcloudImage;
                  imagePullPolicy = "IfNotPresent";
                  securityContext = runAs;
                  command = [
                    "/bin/sh"
                    "-c"
                    "while true; do php -f /var/www/html/cron.php; sleep 300; done"
                  ];
                  resources = {
                    requests = {
                      cpu = "50m";
                      memory = "128Mi";
                    };
                    limits = {
                      cpu = "500m";
                      memory = "512Mi";
                    };
                  };
                  volumeMounts = [
                    {
                      name = "state";
                      mountPath = "/var/lib/nextcloud";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "state";
                  persistentVolumeClaim.claimName = "nextcloud-state";
                }
                {
                  # Same claim, subPath: apps persist without a second PVC.
                  name = "custom-apps";
                  persistentVolumeClaim.claimName = "nextcloud-state";
                }
                {
                  name = "public";
                  persistentVolumeClaim.claimName = "nextcloud-public";
                }
                {
                  name = "collin";
                  persistentVolumeClaim.claimName = "nextcloud-collin";
                }
                {
                  name = "chloe";
                  persistentVolumeClaim.claimName = "nextcloud-chloe";
                }
              ];
            };
          };
        };
      };
      "nextcloud-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "nextcloud";
        };
        spec = {
          selector.app = "nextcloud";
          ports = [
            {
              port = nextcloudPort;
              targetPort = nextcloudPort;
            }
          ];
        };
      };
      "nextcloud-ingress.yaml".content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "nextcloud";
          # Same chains as the edge IngressRoutes (see k3s-traefik-middlewares.nix).
          # forwardAuthGate stays ON here (default) — matches current behavior.
          annotations = {
            "traefik.ingress.kubernetes.io/router.middlewares" =
              middlewaresLib.ingressMiddlewareAnnotation homelab.nextcloud.services.nextcloud;
          };
        };
        spec = {
          ingressClassName = "traefik";
          tls = [
            {
              hosts = [ "nextcloud.diekvoss.net" ];
              secretName = "wildcard-tls-diekvoss-net";
            }
          ];
          rules = [
            {
              host = "nextcloud.diekvoss.net";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "nextcloud";
                    port.number = nextcloudPort;
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
