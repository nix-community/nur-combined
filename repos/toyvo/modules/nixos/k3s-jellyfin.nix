{
  config,
  homelab,
  lib,
  ...
}:
let
  cfg = config.nixcfg.k3sJellyfin;
  middlewaresLib = import ./k3s-traefik-middlewares.nix { inherit lib; };

  # Pinned to the NixOS container's version (pkgs.jellyfin 12.4) — no
  # version migration involved. Tag verified 2026-11-14 against the Docker
  # Hub manifest API (200 on jellyfin/jellyfin:12.4).
  jellyfinImage = "jellyfin/jellyfin:12.4";
  jellyfinPort = homelab.jellyfin.services.jellyfin.port;
in
{
  options.nixcfg.k3sJellyfin = {
    enable = lib.mkEnableOption "Jellyfin in k3s (official image, sqlite seeded from the retired container, DRI passthrough)";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
        message = "nixcfg.k3sJellyfin: manifests must live on a server (nas), never an agent.";
      }
    ];

    services.k3s.manifests = {
      # Single stateful app: sqlite + config seeded cold from the retired
      # container (/mnt/POOL/jellyfin, ~394M) onto local-path (never NFS).
      # Replicas stay 1 from the start: no shared-state hazard exists
      # (cold sqlite copy + read-only media), and manifest=1 is stable
      # across switches (a dark 0 would be reset by every switch — the
      # Immich lesson). Pre-flip the pod serves nothing: the edge route
      # still points at the container until homelab upstreams flip.
      "jellyfin-statefulset.yaml".content = {
        apiVersion = "apps/v1";
        kind = "StatefulSet";
        metadata = {
          name = "jellyfin";
          labels.app = "jellyfin";
        };
        spec = {
          serviceName = "jellyfin";
          replicas = 1;
          selector.matchLabels.app = "jellyfin";
          template = {
            metadata.labels.app = "jellyfin";
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
              # DRI device access (mirrors the container's video/render
              # extraGroups): host video=26, render=303.
              supplementalGroups = [
                26
                303
              ];
              containers = [
                {
                  name = "jellyfin";
                  image = jellyfinImage;
                  imagePullPolicy = "IfNotPresent";
                  # Run as the jellyfin UID (ids.uids.jellyfin = 359,
                  # matching POOL state ownership + media ACLs) instead of
                  # root: the library NFS export uses root_squash, so
                  # root-in-pod is squashed to nobody (Immich lesson).
                  securityContext = {
                    runAsUser = 359;
                    runAsGroup = 359;
                  };
                  env = [
                    {
                      name = "TZ";
                      value = "America/Chicago";
                    }
                  ];
                  ports = [ { containerPort = jellyfinPort; } ];
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
                      name = "config";
                      mountPath = "/config";
                    }
                    {
                      name = "media";
                      mountPath = "/mnt";
                      readOnly = true;
                    }
                    {
                      name = "dri";
                      mountPath = "/dev/dri";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "media";
                  persistentVolumeClaim.claimName = "jellyfin-media";
                }
                {
                  name = "dri";
                  hostPath.path = "/dev/dri";
                }
              ];
            };
          };
          volumeClaimTemplates = [
            {
              metadata.name = "config";
              spec = {
                accessModes = [ "ReadWriteOnce" ];
                resources.requests.storage = "5Gi";
              };
            }
          ];
        };
      };
      "jellyfin-media-pvc.yaml".content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "jellyfin-media";
        };
        spec = {
          # Binds the existing pool-public-ro PV (verified unclaimed):
          # same share, read-only, Retain. PVs bind 1:1, so no second
          # consumer can take it afterwards — a later RO need adds its own.
          accessModes = [ "ReadOnlyMany" ];
          storageClassName = "nfs-pool";
          resources.requests.storage = "100Gi";
        };
      };
      "jellyfin-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "jellyfin";
        };
        spec = {
          selector.app = "jellyfin";
          ports = [
            {
              port = jellyfinPort;
              targetPort = jellyfinPort;
            }
          ];
        };
      };
      "jellyfin-ingress.yaml".content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "jellyfin";
          # Same chains as the edge IngressRoutes (see k3s-traefik-middlewares.nix).
          # forwardAuthGate = false rides along from homelab (LDAP native).
          annotations = {
            "traefik.ingress.kubernetes.io/router.middlewares" =
              middlewaresLib.ingressMiddlewareAnnotation homelab.jellyfin.services.jellyfin;
          };
        };
        spec = {
          ingressClassName = "traefik";
          tls = [
            {
              hosts = [ "jellyfin.diekvoss.net" ];
              secretName = "wildcard-tls-diekvoss-net";
            }
          ];
          rules = [
            {
              host = "jellyfin.diekvoss.net";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "jellyfin";
                    port.number = jellyfinPort;
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
