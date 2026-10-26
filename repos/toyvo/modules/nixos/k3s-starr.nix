{ config, lib, ... }:
let
  cfg = config.nixcfg.k3sStarr;
  # linuxserver.io images honor PUID/PGID; pinned to match the existing
  # state dir ownership (ids.uids/gids.prowlarr = 351).
  prowlarrImage = "lscr.io/linuxserver/prowlarr:2.6.5.5623-ls165";
  prowlarrPort = 9696;
  # nixpkgs ids.uids/gids.sonarr = 274; pinned to match existing ownership.
  sonarrImage = "lscr.io/linuxserver/sonarr:4.0.20.3014-ls329";
  sonarrPort = 8989;
in
{
  options.nixcfg.k3sStarr.prowlarr.enable =
    lib.mkEnableOption "Prowlarr in k3s (first starr migration)";

  options.nixcfg.k3sStarr.sonarr.enable = lib.mkEnableOption "Sonarr in k3s (second starr migration)";

  # Single writer: enable ONLY on nas. See k3s-storage.nix for why.
  config = lib.mkMerge [
    (lib.mkIf cfg.prowlarr.enable {
      assertions = [
        {
          assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
          message = "nixcfg.k3sStarr: starr manifests must live on a server (nas), never an agent.";
        }
      ];

      services.k3s.manifests = {
        "prowlarr-statefulset.yaml".content = {
          apiVersion = "apps/v1";
          kind = "StatefulSet";
          metadata = {
            name = "prowlarr";
            labels.app = "prowlarr";
          };
          spec = {
            serviceName = "prowlarr";
            replicas = 1;
            selector.matchLabels.app = "prowlarr";
            template = {
              metadata.labels.app = "prowlarr";
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
                    name = "prowlarr";
                    image = prowlarrImage;
                    imagePullPolicy = "IfNotPresent";
                    env = [
                      {
                        name = "PUID";
                        value = "351";
                      }
                      {
                        name = "PGID";
                        value = "351";
                      }
                      {
                        name = "TZ";
                        value = "America/Chicago";
                      }
                    ];
                    ports = [ { containerPort = prowlarrPort; } ];
                    resources = {
                      requests = {
                        cpu = "50m";
                        memory = "128Mi";
                      };
                      limits = {
                        cpu = "1000m";
                        memory = "1Gi";
                      };
                    };
                    volumeMounts = [
                      {
                        name = "config";
                        mountPath = "/config";
                      }
                    ];
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
        "prowlarr-service.yaml".content = {
          apiVersion = "v1";
          kind = "Service";
          metadata = {
            name = "prowlarr";
          };
          spec = {
            selector.app = "prowlarr";
            ports = [
              {
                port = prowlarrPort;
                targetPort = prowlarrPort;
              }
            ];
          };
        };
        "prowlarr-ingress.yaml".content = {
          apiVersion = "networking.k8s.io/v1";
          kind = "Ingress";
          metadata = {
            name = "prowlarr";
          };
          spec = {
            ingressClassName = "traefik";
            rules = [
              {
                host = "prowlarr.diekvoss.net";
                http.paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend.service = {
                      name = "prowlarr";
                      port.number = prowlarrPort;
                    };
                  }
                ];
              }
            ];
          };
        };
      };
    })
    (lib.mkIf cfg.sonarr.enable {
      assertions = [
        {
          assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
          message = "nixcfg.k3sStarr: starr manifests must live on a server (nas), never an agent.";
        }
      ];

      services.k3s.manifests = {
        "sonarr-media-pvc.yaml".content = {
          apiVersion = "v1";
          kind = "PersistentVolumeClaim";
          metadata = {
            name = "sonarr-media";
          };
          spec = {
            accessModes = [ "ReadWriteMany" ];
            storageClassName = "nfs-pool";
            resources.requests.storage = "100Gi";
          };
        };
        "sonarr-statefulset.yaml".content = {
          apiVersion = "apps/v1";
          kind = "StatefulSet";
          metadata = {
            name = "sonarr";
            labels.app = "sonarr";
          };
          spec = {
            serviceName = "sonarr";
            replicas = 1;
            selector.matchLabels.app = "sonarr";
            template = {
              metadata.labels.app = "sonarr";
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
                    name = "sonarr";
                    image = sonarrImage;
                    imagePullPolicy = "IfNotPresent";
                    env = [
                      {
                        name = "PUID";
                        value = "274";
                      }
                      {
                        name = "PGID";
                        value = "274";
                      }
                      {
                        name = "TZ";
                        value = "America/Chicago";
                      }
                    ];
                    ports = [ { containerPort = sonarrPort; } ];
                    resources = {
                      requests = {
                        cpu = "50m";
                        memory = "256Mi";
                      };
                      limits = {
                        cpu = "1000m";
                        memory = "2Gi";
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
                      }
                    ];
                  }
                ];
                volumes = [
                  {
                    name = "media";
                    persistentVolumeClaim.claimName = "sonarr-media";
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
        "sonarr-service.yaml".content = {
          apiVersion = "v1";
          kind = "Service";
          metadata = {
            name = "sonarr";
          };
          spec = {
            selector.app = "sonarr";
            ports = [
              {
                port = sonarrPort;
                targetPort = sonarrPort;
              }
            ];
          };
        };
        "sonarr-ingress.yaml".content = {
          apiVersion = "networking.k8s.io/v1";
          kind = "Ingress";
          metadata = {
            name = "sonarr";
          };
          spec = {
            ingressClassName = "traefik";
            rules = [
              {
                host = "sonarr.diekvoss.net";
                http.paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend.service = {
                      name = "sonarr";
                      port.number = sonarrPort;
                    };
                  }
                ];
              }
            ];
          };
        };
      };
    })
  ];
}
