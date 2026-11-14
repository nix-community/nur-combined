{
  config,
  homelab,
  lib,
  ...
}:
let
  cfg = config.nixcfg.k3sImmich;
  middlewaresLib = import ./k3s-traefik-middlewares.nix { inherit lib; };

  # Pinned to the NixOS container's version (pkgs.immich 3.3.6) — no
  # version migration involved. Tags verified 2026-11-14 against
  # ghcr.io/docker.io manifest APIs (skopeo not installed here):
  #   immich-server v3.3.6, immich-machine-learning v3.3.6,
  #   postgres 14-vectorchord0.4.3-pgvectors0.2.0 (the tag upstream's
  #   v3.3.6 docker-compose.yml pins, with digest
  #   sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23),
  #   valkey/valkey:9 (digest
  #   sha256:c123e3715db63d06d4ad6964884037aa0d5d4d703939b9929954112889708e1d).
  immichServerImage = "ghcr.io/immich-app/immich-server:v3.3.6";
  immichMachineLearningImage = "ghcr.io/immich-app/immich-machine-learning:v3.3.6";
  immichPostgresImage = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0";
  immichValkeyImage = "docker.io/valkey/valkey:9";
  immichPort = 2283;

  # Upstream compose mounts the library at /data (NOT /usr/src/app/upload;
  # NOT the NixOS module's /var/lib/immich). IMMICH_MEDIA_LOCATION is
  # unset so the server default (/data) applies.
  libraryMountPath = "/data";
in
{
  options.nixcfg.k3sImmich = {
    enable = lib.mkEnableOption "Immich in k3s (server + ML + Postgres + Valkey, seeded from the retired container)";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
        message = "nixcfg.k3sImmich: manifests must live on a server (nas), never an agent.";
      }
    ];

    services.k3s.manifests = {
      # Postgres owns the irreplaceable state (users, assets, albums,
      # faces, API keys, OAuth). local-path ONLY — never NFS.
      # Seeded on cutover day via pg_dumpall from the live container
      # (DB name `immich`, role `immich`, matching the NixOS module
      # defaults); server env below uses the same names.
      # NOTE: DB_PASSWORD must be A-Za-z0-9 only (no special chars or
      # spaces — upstream .env constraint). Created out-of-band via
      # k8s/immich/secretspec.toml, never in the Nix store.
      "immich-postgres-statefulset.yaml".content = {
        apiVersion = "apps/v1";
        kind = "StatefulSet";
        metadata = {
          name = "immich-postgres";
          labels.app = "immich-postgres";
        };
        spec = {
          serviceName = "immich-postgres";
          replicas = 1;
          selector.matchLabels.app = "immich-postgres";
          template = {
            metadata.labels.app = "immich-postgres";
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
                  image = immichPostgresImage;
                  imagePullPolicy = "IfNotPresent";
                  env = [
                    {
                      name = "POSTGRES_USER";
                      value = "postgres";
                    }
                    {
                      name = "POSTGRES_DB";
                      value = "immich";
                    }
                    {
                      name = "POSTGRES_PASSWORD";
                      valueFrom.secretKeyRef = {
                        name = "immich-db";
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
                      memory = "512Mi";
                    };
                    limits = {
                      cpu = "2000m";
                      memory = "4Gi";
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
                resources.requests.storage = "10Gi";
              };
            }
          ];
        };
      };
      "immich-postgres-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "immich-postgres";
        };
        spec = {
          selector.app = "immich-postgres";
          ports = [
            {
              port = 5432;
              targetPort = 5432;
            }
          ];
        };
      };
      # Valkey is cache-only (job queue + sessions): no volumes, ephemeral
      # by design. A restart drops queued jobs; the server re-queues on
      # demand. Documented, accepted.
      "immich-valkey-deployment.yaml".content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "immich-valkey";
          labels.app = "immich-valkey";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "immich-valkey";
          template = {
            metadata.labels.app = "immich-valkey";
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
                  name = "valkey";
                  image = immichValkeyImage;
                  imagePullPolicy = "IfNotPresent";
                  ports = [ { containerPort = 6379; } ];
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
                }
              ];
            };
          };
        };
      };
      "immich-valkey-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "immich-valkey";
        };
        spec = {
          selector.app = "immich-valkey";
          ports = [
            {
              port = 6379;
              targetPort = 6379;
            }
          ];
        };
      };
      "immich-library-pvc.yaml".content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "immich-library";
        };
        spec = {
          accessModes = [ "ReadWriteMany" ];
          storageClassName = "nfs-pool";
          resources.requests.storage = "100Gi";
        };
      };
      # Replicas are 1 post-cutover (container retired 2026-11-14, DB
      # restored + verified). Dark phase used 0 to enforce the
      # never-run-two-servers anti-goal; do NOT scale back to 0.
      "immich-server-deployment.yaml".content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "immich-server";
          labels.app = "immich-server";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "immich-server";
          template = {
            metadata.labels.app = "immich-server";
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
                  name = "immich-server";
                  image = immichServerImage;
                  imagePullPolicy = "IfNotPresent";
                  # Run as the immich UID (ids.uids.immich = 354, matching
                  # POOL file ownership + the /mnt/POOL/immich ACLs) instead
                  # of root: the library NFS export uses root_squash, so
                  # root-in-pod is squashed to nobody and the startup
                  # folder-integrity writes (`.immich` sentinels) die with
                  # EACCES. Non-root numeric UID passes NFS untouched.
                  # No fsGroup: it would recursively chown the 101G library
                  # mount on every pod start.
                  securityContext = {
                    runAsUser = 354;
                    runAsGroup = 354;
                  };
                  env = [
                    {
                      name = "DB_HOSTNAME";
                      value = "immich-postgres";
                    }
                    {
                      name = "DB_PORT";
                      value = "5432";
                    }
                    {
                      name = "DB_USERNAME";
                      value = "immich";
                    }
                    {
                      name = "DB_DATABASE_NAME";
                      value = "immich";
                    }
                    {
                      name = "DB_PASSWORD";
                      valueFrom.secretKeyRef = {
                        name = "immich-db";
                        key = "DB_PASSWORD";
                      };
                    }
                    {
                      name = "REDIS_HOSTNAME";
                      value = "immich-valkey";
                    }
                    {
                      name = "REDIS_PORT";
                      value = "6379";
                    }
                    {
                      name = "TZ";
                      value = "America/Chicago";
                    }
                  ];
                  ports = [ { containerPort = immichPort; } ];
                  resources = {
                    requests = {
                      cpu = "200m";
                      memory = "1Gi";
                    };
                    limits = {
                      cpu = "4000m";
                      memory = "8Gi";
                    };
                  };
                  volumeMounts = [
                    {
                      name = "library";
                      mountPath = libraryMountPath;
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "library";
                  persistentVolumeClaim.claimName = "immich-library";
                }
              ];
            };
          };
        };
      };
      "immich-server-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "immich-server";
        };
        spec = {
          selector.app = "immich-server";
          ports = [
            {
              port = immichPort;
              targetPort = immichPort;
            }
          ];
        };
      };
      # ML model cache seeded by rsync from /mnt/POOL/immich/cache on
      # cutover day (several GB — don't redownload). local-path, nas-only.
      "immich-machine-learning-deployment.yaml".content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "immich-machine-learning";
          labels.app = "immich-machine-learning";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "immich-machine-learning";
          template = {
            metadata.labels.app = "immich-machine-learning";
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
                  name = "immich-machine-learning";
                  image = immichMachineLearningImage;
                  imagePullPolicy = "IfNotPresent";
                  env = [
                    {
                      name = "TZ";
                      value = "America/Chicago";
                    }
                  ];
                  ports = [ { containerPort = 3003; } ];
                  resources = {
                    requests = {
                      cpu = "200m";
                      memory = "512Mi";
                    };
                    limits = {
                      cpu = "4000m";
                      memory = "8Gi";
                    };
                  };
                  volumeMounts = [
                    {
                      name = "model-cache";
                      mountPath = "/cache";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "model-cache";
                  persistentVolumeClaim.claimName = "immich-model-cache";
                }
              ];
            };
          };
        };
      };
      "immich-model-cache-pvc.yaml".content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "immich-model-cache";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          resources.requests.storage = "10Gi";
        };
      };
      "immich-machine-learning-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "immich-machine-learning";
        };
        spec = {
          selector.app = "immich-machine-learning";
          ports = [
            {
              port = 3003;
              targetPort = 3003;
            }
          ];
        };
      };
      "immich-ingress.yaml".content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "immich";
          # Same chains as the edge IngressRoutes (see k3s-traefik-middlewares.nix).
          # forwardAuthGate = false rides along from homelab (native OIDC).
          annotations = {
            "traefik.ingress.kubernetes.io/router.middlewares" =
              middlewaresLib.ingressMiddlewareAnnotation homelab.immich.services.immich;
          };
        };
        spec = {
          ingressClassName = "traefik";
          tls = [
            {
              hosts = [ "immich.diekvoss.net" ];
              secretName = "wildcard-tls-diekvoss-net";
            }
          ];
          rules = [
            {
              host = "immich.diekvoss.net";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "immich-server";
                    port.number = immichPort;
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
