{
  config,
  lib,
  ...
}:
let
  cfg = config.nixcfg.k3sOffice;
  middlewaresLib = import ./k3s-traefik-middlewares.nix { inherit lib; };

  # Pinned to the release verified 2026-11-14 against the ghcr manifest API
  # (200 on ghcr.io/euro-office/documentserver:v9.3.1) — no version drift.
  officeImage = "ghcr.io/euro-office/documentserver:v9.3.1";
  officePort = 80;
in
{
  options.nixcfg.k3sOffice = {
    enable = lib.mkEnableOption "Euro-Office Document Server in k3s (all-in-one image, JWT-secured, no forward-auth)";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
        message = "nixcfg.k3sOffice: manifests must live on a server (nas), never an agent.";
      }
    ];

    services.k3s.manifests = {
      # All-in-one image (bundled services, like upstream's docker run) —
      # deliberately NOT the Helm chart's split docservice/converter shape
      # (that's for scale-out; here one writer owns everything).
      # StatefulSet, not Deployment: volumeClaimTemplates are a
      # StatefulSet-only field (a Deployment carrying them is accepted
      # but never provisions the claims — pod stays Pending forever).
      "euro-office-statefulset.yaml".content = {
        apiVersion = "apps/v1";
        kind = "StatefulSet";
        metadata = {
          name = "euro-office";
          labels.app = "euro-office";
        };
        spec = {
          serviceName = "euro-office";
          replicas = 1;
          selector.matchLabels.app = "euro-office";
          template = {
            metadata.labels.app = "euro-office";
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
                  name = "euro-office";
                  image = officeImage;
                  imagePullPolicy = "IfNotPresent";
                  env = [
                    {
                      name = "JWT_ENABLED";
                      value = "true";
                    }
                    {
                      name = "JWT_SECRET";
                      valueFrom.secretKeyRef = {
                        name = "euro-office-jwt";
                        key = "JWT_SECRET";
                      };
                    }
                    {
                      name = "JWT_HEADER";
                      value = "Authorization";
                    }
                    {
                      name = "EXAMPLE_ENABLED";
                      value = "false";
                    }
                    # All DS<->Nextcloud traffic is cluster/LAN-private;
                    # the default (false) would refuse the callbacks.
                    {
                      name = "ALLOW_PRIVATE_IP_ADDRESS";
                      value = "true";
                    }
                    {
                      name = "TZ";
                      value = "America/Chicago";
                    }
                  ];
                  ports = [ { containerPort = officePort; } ];
                  # First boot does DB init + font/cache generation (minutes).
                  # Without initial delays the probes SIGKILL the pod mid-boot
                  # (exit 137 crashloop) before it can ever listen.
                  readinessProbe = {
                    httpGet = {
                      path = "/healthcheck";
                      port = officePort;
                    };
                    initialDelaySeconds = 120;
                    periodSeconds = 30;
                  };
                  livenessProbe = {
                    httpGet = {
                      path = "/healthcheck";
                      port = officePort;
                    };
                    initialDelaySeconds = 180;
                    periodSeconds = 60;
                  };
                  resources = {
                    requests = {
                      cpu = "500m";
                      memory = "2Gi";
                    };
                    limits = {
                      cpu = "4000m";
                      memory = "8Gi";
                    };
                  };
                  volumeMounts = [
                    {
                      name = "data";
                      mountPath = "/var/lib/euro-office/documentserver";
                    }
                    {
                      name = "private";
                      mountPath = "/var/www/euro-office/Data";
                    }
                    {
                      name = "shm";
                      mountPath = "/dev/shm";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "data";
                  persistentVolumeClaim.claimName = "euro-office-data";
                }
                {
                  name = "private";
                  persistentVolumeClaim.claimName = "euro-office-private";
                }
                {
                  # Document conversion is chromium-based and fails under
                  # the 64Mi default shm (provision first, don't debug later).
                  name = "shm";
                  emptyDir = {
                    medium = "Memory";
                    sizeLimit = "2Gi";
                  };
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
            {
              metadata.name = "private";
              spec = {
                accessModes = [ "ReadWriteOnce" ];
                resources.requests.storage = "5Gi";
              };
            }
          ];
        };
      };
      "euro-office-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "euro-office";
        };
        spec = {
          selector.app = "euro-office";
          ports = [
            {
              port = officePort;
              targetPort = officePort;
            }
          ];
        };
      };
      "euro-office-ingress.yaml".content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "euro-office";
          # No forward-auth annotation on purpose: the Document Server
          # authenticates via its own JWT (like the *arrs/Immich opt-outs —
          # and gating it would break DS<->Nextcloud callbacks).
          annotations = {
            "traefik.ingress.kubernetes.io/router.middlewares" = middlewaresLib.ingressMiddlewareAnnotation {
              domain = "diekvoss.net";
              public = false;
              forwardAuthGate = false;
            };
          };
        };
        spec = {
          ingressClassName = "traefik";
          tls = [
            {
              hosts = [ "office.diekvoss.net" ];
              secretName = "wildcard-tls-diekvoss-net";
            }
          ];
          rules = [
            {
              host = "office.diekvoss.net";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "euro-office";
                    port.number = officePort;
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
