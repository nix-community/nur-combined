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
  # nixpkgs ids.uids/gids.lidarr = 306; pinned to match existing ownership.
  lidarrImage = "lscr.io/linuxserver/lidarr:3.1.6.5079-ls46";
  lidarrPort = 8686;
  # nixpkgs ids.uids/gids.radarr = 275; pinned to match existing ownership.
  radarrImage = "lscr.io/linuxserver/radarr:6.4.4.10685-ls324";
  radarrPort = 7878;
  # nixpkgs ids.uids/gids.readarr = 352; pinned to match existing ownership.
  # Readarr has no stable release (discontinued upstream); pinned develop tag verified against hub.
  readarrImage = "lscr.io/linuxserver/readarr:develop-0.4.18.2805-ls157";
  readarrPort = 8787;
  # nixpkgs ids.uids/gids.bazarr = 350; pinned to match existing ownership.
  bazarrImage = "lscr.io/linuxserver/bazarr:v1.6.2-ls369";
  bazarrPort = 6767;
  # No linuxserver build; official image, pinned and hub-verified. Stateless: no PUID/PGID, no volumes.
  flaresolverrImage = "flaresolverr/flaresolverr:v3.5.2";
  flaresolverrPort = 8191;
  # nixpkgs ids.uids/gids.qbittorrent = 353; pinned to match existing ownership.
  qbittorrentImage = "lscr.io/linuxserver/qbittorrent:5.3.0_v2.1.2-ls485";
  wireguardImage = "lscr.io/linuxserver/wireguard:1.0.20260223-r0-ls127";
  qbittorrentPort = 4080;
in
{
  options.nixcfg.k3sStarr.prowlarr.enable =
    lib.mkEnableOption "Prowlarr in k3s (first starr migration)";

  options.nixcfg.k3sStarr.sonarr.enable = lib.mkEnableOption "Sonarr in k3s (second starr migration)";

  options.nixcfg.k3sStarr.lidarr.enable = lib.mkEnableOption "Lidarr in k3s (third starr migration)";

  options.nixcfg.k3sStarr.radarr.enable = lib.mkEnableOption "Radarr in k3s (fourth starr migration)";

  options.nixcfg.k3sStarr.readarr.enable =
    lib.mkEnableOption "Readarr in k3s (fifth starr migration)";

  options.nixcfg.k3sStarr.bazarr.enable = lib.mkEnableOption "Bazarr in k3s (sixth starr migration)";

  options.nixcfg.k3sStarr.flaresolverr.enable =
    lib.mkEnableOption "FlareSolverr in k3s (stateless solver for prowlarr)";

  options.nixcfg.k3sStarr.qbittorrent.enable =
    lib.mkEnableOption "qBittorrent in k3s (VPN-isolated pod: wireguard + kill-switch + port-forward)";

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
    (lib.mkIf cfg.lidarr.enable {
      assertions = [
        {
          assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
          message = "nixcfg.k3sStarr: starr manifests must live on a server (nas), never an agent.";
        }
      ];

      services.k3s.manifests = {
        "lidarr-media-pvc.yaml".content = {
          apiVersion = "v1";
          kind = "PersistentVolumeClaim";
          metadata = {
            name = "lidarr-media";
          };
          spec = {
            accessModes = [ "ReadWriteMany" ];
            storageClassName = "nfs-pool";
            resources.requests.storage = "100Gi";
          };
        };
        "lidarr-statefulset.yaml".content = {
          apiVersion = "apps/v1";
          kind = "StatefulSet";
          metadata = {
            name = "lidarr";
            labels.app = "lidarr";
          };
          spec = {
            serviceName = "lidarr";
            replicas = 1;
            selector.matchLabels.app = "lidarr";
            template = {
              metadata.labels.app = "lidarr";
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
                    name = "lidarr";
                    image = lidarrImage;
                    imagePullPolicy = "IfNotPresent";
                    env = [
                      {
                        name = "PUID";
                        value = "306";
                      }
                      {
                        name = "PGID";
                        value = "306";
                      }
                      {
                        name = "TZ";
                        value = "America/Chicago";
                      }
                    ];
                    ports = [ { containerPort = lidarrPort; } ];
                    resources = {
                      requests = {
                        cpu = "50m";
                        memory = "128Mi";
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
                    persistentVolumeClaim.claimName = "lidarr-media";
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
        "lidarr-service.yaml".content = {
          apiVersion = "v1";
          kind = "Service";
          metadata = {
            name = "lidarr";
          };
          spec = {
            selector.app = "lidarr";
            ports = [
              {
                port = lidarrPort;
                targetPort = lidarrPort;
              }
            ];
          };
        };
        "lidarr-ingress.yaml".content = {
          apiVersion = "networking.k8s.io/v1";
          kind = "Ingress";
          metadata = {
            name = "lidarr";
          };
          spec = {
            ingressClassName = "traefik";
            rules = [
              {
                host = "lidarr.diekvoss.net";
                http.paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend.service = {
                      name = "lidarr";
                      port.number = lidarrPort;
                    };
                  }
                ];
              }
            ];
          };
        };
      };
    })
    (lib.mkIf cfg.radarr.enable {
      assertions = [
        {
          assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
          message = "nixcfg.k3sStarr: starr manifests must live on a server (nas), never an agent.";
        }
      ];

      services.k3s.manifests = {
        "radarr-media-pvc.yaml".content = {
          apiVersion = "v1";
          kind = "PersistentVolumeClaim";
          metadata = {
            name = "radarr-media";
          };
          spec = {
            accessModes = [ "ReadWriteMany" ];
            storageClassName = "nfs-pool";
            resources.requests.storage = "100Gi";
          };
        };
        "radarr-statefulset.yaml".content = {
          apiVersion = "apps/v1";
          kind = "StatefulSet";
          metadata = {
            name = "radarr";
            labels.app = "radarr";
          };
          spec = {
            serviceName = "radarr";
            replicas = 1;
            selector.matchLabels.app = "radarr";
            template = {
              metadata.labels.app = "radarr";
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
                    name = "radarr";
                    image = radarrImage;
                    imagePullPolicy = "IfNotPresent";
                    env = [
                      {
                        name = "PUID";
                        value = "275";
                      }
                      {
                        name = "PGID";
                        value = "275";
                      }
                      {
                        name = "TZ";
                        value = "America/Chicago";
                      }
                    ];
                    ports = [ { containerPort = radarrPort; } ];
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
                    persistentVolumeClaim.claimName = "radarr-media";
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
        "radarr-service.yaml".content = {
          apiVersion = "v1";
          kind = "Service";
          metadata = {
            name = "radarr";
          };
          spec = {
            selector.app = "radarr";
            ports = [
              {
                port = radarrPort;
                targetPort = radarrPort;
              }
            ];
          };
        };
        "radarr-ingress.yaml".content = {
          apiVersion = "networking.k8s.io/v1";
          kind = "Ingress";
          metadata = {
            name = "radarr";
          };
          spec = {
            ingressClassName = "traefik";
            rules = [
              {
                host = "radarr.diekvoss.net";
                http.paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend.service = {
                      name = "radarr";
                      port.number = radarrPort;
                    };
                  }
                ];
              }
            ];
          };
        };
      };
    })
    (lib.mkIf cfg.readarr.enable {
      assertions = [
        {
          assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
          message = "nixcfg.k3sStarr: starr manifests must live on a server (nas), never an agent.";
        }
      ];

      services.k3s.manifests = {
        "readarr-media-pvc.yaml".content = {
          apiVersion = "v1";
          kind = "PersistentVolumeClaim";
          metadata = {
            name = "readarr-media";
          };
          spec = {
            accessModes = [ "ReadWriteMany" ];
            storageClassName = "nfs-pool";
            resources.requests.storage = "100Gi";
          };
        };
        "readarr-statefulset.yaml".content = {
          apiVersion = "apps/v1";
          kind = "StatefulSet";
          metadata = {
            name = "readarr";
            labels.app = "readarr";
          };
          spec = {
            serviceName = "readarr";
            replicas = 1;
            selector.matchLabels.app = "readarr";
            template = {
              metadata.labels.app = "readarr";
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
                    name = "readarr";
                    image = readarrImage;
                    imagePullPolicy = "IfNotPresent";
                    env = [
                      {
                        name = "PUID";
                        value = "352";
                      }
                      {
                        name = "PGID";
                        value = "352";
                      }
                      {
                        name = "TZ";
                        value = "America/Chicago";
                      }
                    ];
                    ports = [ { containerPort = readarrPort; } ];
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
                    persistentVolumeClaim.claimName = "readarr-media";
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
        "readarr-service.yaml".content = {
          apiVersion = "v1";
          kind = "Service";
          metadata = {
            name = "readarr";
          };
          spec = {
            selector.app = "readarr";
            ports = [
              {
                port = readarrPort;
                targetPort = readarrPort;
              }
            ];
          };
        };
        "readarr-ingress.yaml".content = {
          apiVersion = "networking.k8s.io/v1";
          kind = "Ingress";
          metadata = {
            name = "readarr";
          };
          spec = {
            ingressClassName = "traefik";
            rules = [
              {
                host = "readarr.diekvoss.net";
                http.paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend.service = {
                      name = "readarr";
                      port.number = readarrPort;
                    };
                  }
                ];
              }
            ];
          };
        };
      };
    })
    (lib.mkIf cfg.bazarr.enable {
      assertions = [
        {
          assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
          message = "nixcfg.k3sStarr: starr manifests must live on a server (nas), never an agent.";
        }
      ];

      services.k3s.manifests = {
        "bazarr-media-pvc.yaml".content = {
          apiVersion = "v1";
          kind = "PersistentVolumeClaim";
          metadata = {
            name = "bazarr-media";
          };
          spec = {
            accessModes = [ "ReadWriteMany" ];
            storageClassName = "nfs-pool";
            resources.requests.storage = "100Gi";
          };
        };
        "bazarr-statefulset.yaml".content = {
          apiVersion = "apps/v1";
          kind = "StatefulSet";
          metadata = {
            name = "bazarr";
            labels.app = "bazarr";
          };
          spec = {
            serviceName = "bazarr";
            replicas = 1;
            selector.matchLabels.app = "bazarr";
            template = {
              metadata.labels.app = "bazarr";
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
                    name = "bazarr";
                    image = bazarrImage;
                    imagePullPolicy = "IfNotPresent";
                    env = [
                      {
                        name = "PUID";
                        value = "350";
                      }
                      {
                        name = "PGID";
                        value = "350";
                      }
                      {
                        name = "TZ";
                        value = "America/Chicago";
                      }
                    ];
                    ports = [ { containerPort = bazarrPort; } ];
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
                    persistentVolumeClaim.claimName = "bazarr-media";
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
        "bazarr-service.yaml".content = {
          apiVersion = "v1";
          kind = "Service";
          metadata = {
            name = "bazarr";
          };
          spec = {
            selector.app = "bazarr";
            ports = [
              {
                port = bazarrPort;
                targetPort = bazarrPort;
              }
            ];
          };
        };
        "bazarr-ingress.yaml".content = {
          apiVersion = "networking.k8s.io/v1";
          kind = "Ingress";
          metadata = {
            name = "bazarr";
          };
          spec = {
            ingressClassName = "traefik";
            rules = [
              {
                host = "bazarr.diekvoss.net";
                http.paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend.service = {
                      name = "bazarr";
                      port.number = bazarrPort;
                    };
                  }
                ];
              }
            ];
          };
        };
      };
    })
    (lib.mkIf cfg.flaresolverr.enable {
      assertions = [
        {
          assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
          message = "nixcfg.k3sStarr: starr manifests must live on a server (nas), never an agent.";
        }
      ];

      services.k3s.manifests = {
        "flaresolverr-statefulset.yaml".content = {
          apiVersion = "apps/v1";
          kind = "StatefulSet";
          metadata = {
            name = "flaresolverr";
            labels.app = "flaresolverr";
          };
          spec = {
            serviceName = "flaresolverr";
            replicas = 1;
            selector.matchLabels.app = "flaresolverr";
            template = {
              metadata.labels.app = "flaresolverr";
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
                    name = "flaresolverr";
                    image = flaresolverrImage;
                    imagePullPolicy = "IfNotPresent";
                    env = [
                      {
                        name = "TZ";
                        value = "America/Chicago";
                      }
                    ];
                    ports = [ { containerPort = flaresolverrPort; } ];
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
                  }
                ];
              };
            };
          };
        };
        "flaresolverr-service.yaml".content = {
          apiVersion = "v1";
          kind = "Service";
          metadata = {
            name = "flaresolverr";
          };
          spec = {
            selector.app = "flaresolverr";
            ports = [
              {
                port = flaresolverrPort;
                targetPort = flaresolverrPort;
              }
            ];
          };
        };
        "flaresolverr-ingress.yaml".content = {
          apiVersion = "networking.k8s.io/v1";
          kind = "Ingress";
          metadata = {
            name = "flaresolverr";
          };
          spec = {
            ingressClassName = "traefik";
            rules = [
              {
                host = "flaresolverr.diekvoss.net";
                http.paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend.service = {
                      name = "flaresolverr";
                      port.number = flaresolverrPort;
                    };
                  }
                ];
              }
            ];
          };
        };
      };
    })
    (lib.mkIf cfg.qbittorrent.enable {
      assertions = [
        {
          assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
          message = "nixcfg.k3sStarr: starr manifests must live on a server (nas), never an agent.";
        }
      ];

      services.k3s.manifests = {
        "qbittorrent-media-pvc.yaml".content = {
          apiVersion = "v1";
          kind = "PersistentVolumeClaim";
          metadata = {
            name = "qbittorrent-media";
          };
          spec = {
            accessModes = [ "ReadWriteMany" ];
            storageClassName = "nfs-pool";
            resources.requests.storage = "100Gi";
          };
        };
        "qbittorrent-statefulset.yaml".content = {
          apiVersion = "apps/v1";
          kind = "StatefulSet";
          metadata = {
            name = "qbittorrent";
            labels.app = "qbittorrent";
          };
          spec = {
            serviceName = "qbittorrent";
            replicas = 1;
            selector.matchLabels.app = "qbittorrent";
            template = {
              metadata.labels.app = "qbittorrent";
              spec = {
                # DNS through the tunnel only: tracker lookups must never
                # leak to LAN/ISP. Fails closed with the tunnel.
                dnsPolicy = "None";
                dnsConfig.nameservers = [ "10.2.0.1" ];
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
                # No initContainer: the kill-switch (nft) and split-tunnel
                # rules live in wg0.conf's PostUp (Secret-managed), which owns
                # every rule/route with explicit prefs. An init-time ip rule
                # would collide with PostUp's explicit pref and abort the
                # tunnel; apk can't run pre-tunnel anyway (no DNS yet).
                containers = [
                  {
                    name = "wireguard";
                    image = wireguardImage;
                    imagePullPolicy = "IfNotPresent";
                    env = [
                      {
                        name = "PUID";
                        value = "353";
                      }
                      {
                        name = "PGID";
                        value = "353";
                      }
                      {
                        name = "TZ";
                        value = "America/Chicago";
                      }
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
                    securityContext.capabilities.add = [
                      "NET_ADMIN"
                      "SYS_MODULE"
                    ];
                    volumeMounts = [
                      {
                        name = "vpn-config";
                        mountPath = "/config/wg0.conf";
                        subPath = "wg0.conf";
                      }
                    ];
                  }
                  {
                    name = "qbittorrent";
                    image = qbittorrentImage;
                    imagePullPolicy = "IfNotPresent";
                    env = [
                      {
                        name = "PUID";
                        value = "353";
                      }
                      {
                        name = "PGID";
                        value = "353";
                      }
                      {
                        name = "TZ";
                        value = "America/Chicago";
                      }
                      # The image hardcodes --webui-port on the command line,
                      # overriding the config file: the env var is the only
                      # way to match the Service port.
                      {
                        name = "WEBUI_PORT";
                        value = "4080";
                      }
                    ];
                    ports = [ { containerPort = qbittorrentPort; } ];
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
                        name = "config";
                        mountPath = "/config";
                      }
                      {
                        name = "media";
                        mountPath = "/mnt";
                      }
                      # Transitional: live fastresume state references the old
                      # container paths (/var/lib/qBittorrent/...). Mounts the
                      # same host dir so existing torrents resume in place.
                      # Remove once old downloads are migrated to /mnt/Downloads.
                      {
                        name = "legacy-state";
                        mountPath = "/var/lib/qBittorrent";
                      }
                    ];
                  }
                  {
                    name = "port-forward";
                    image = "alpine:3.21.9";
                    imagePullPolicy = "IfNotPresent";
                    command = [
                      "/bin/sh"
                      "-c"
                      ''
                        apk add --no-cache natpmpc curl
                        # Give qbittorrent's web server time to come up.
                        sleep 5
                        while true; do
                          tcp_out=$(natpmpc -a 1 0 tcp 60 -g 10.2.0.1 2>&1) || true
                          natpmpc -a 1 0 udp 60 -g 10.2.0.1 >/dev/null 2>&1 || true
                          port=$(printf '%s\n' "$tcp_out" | grep "Mapped public port" | awk '{print $4}')
                          if [ -n "$port" ]; then
                            echo "NAT-PMP mapped port $port — updating qBittorrent listen port"
                            curl -sf -X POST "http://127.0.0.1:4080/api/v2/app/setPreferences" \
                              --data-urlencode "{\"listen_port\": $port}" \
                              -o /dev/null || echo "Failed to update listen port (will retry)"
                          else
                            echo "NAT-PMP request failed:"
                            printf '%s\n' "$tcp_out"
                          fi
                          sleep 45
                        done
                      ''
                    ];
                    resources = {
                      requests = {
                        cpu = "10m";
                        memory = "32Mi";
                      };
                      limits = {
                        cpu = "100m";
                        memory = "128Mi";
                      };
                    };
                  }
                ];
                volumes = [
                  {
                    name = "vpn-config";
                    secret.secretName = "qbittorrent-vpn";
                  }
                  {
                    name = "media";
                    persistentVolumeClaim.claimName = "qbittorrent-media";
                  }
                  {
                    name = "legacy-state";
                    hostPath.path = "/mnt/POOL/starr/qbittorrent";
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
        "qbittorrent-service.yaml".content = {
          apiVersion = "v1";
          kind = "Service";
          metadata = {
            name = "qbittorrent";
          };
          spec = {
            selector.app = "qbittorrent";
            ports = [
              {
                port = qbittorrentPort;
                targetPort = qbittorrentPort;
              }
            ];
          };
        };
        "qbittorrent-ingress.yaml".content = {
          apiVersion = "networking.k8s.io/v1";
          kind = "Ingress";
          metadata = {
            name = "qbittorrent";
          };
          spec = {
            ingressClassName = "traefik";
            rules = [
              {
                host = "qbittorrent.diekvoss.net";
                http.paths = [
                  {
                    path = "/";
                    pathType = "Prefix";
                    backend.service = {
                      name = "qbittorrent";
                      port.number = qbittorrentPort;
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
