{
  config,
  homelab,
  lib,
  ...
}:
let
  cfg = config.nixcfg.k3sHomeassistant;
  middlewaresLib = import ./k3s-traefik-middlewares.nix { inherit lib; };

  # Mirrors the nixpkgs services.home-assistant 2026.5.4 the hass container
  # runs (exact image tag below) — no version migration involved.
  homeassistantImage = "homeassistant/home-assistant:2026.5.4";
  homeassistantPort = 8123;
in
{
  options.nixcfg.k3sHomeassistant = {
    enable = lib.mkEnableOption "Home Assistant in k3s (container hass retired)";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
        message = "nixcfg.k3sHomeassistant: manifests must live on a server (nas), never an agent.";
      }
    ];

    services.k3s.manifests = {
      "home-assistant-statefulset.yaml".content = {
        apiVersion = "apps/v1";
        kind = "StatefulSet";
        metadata = {
          name = "home-assistant";
          labels.app = "home-assistant";
        };
        spec = {
          serviceName = "home-assistant";
          replicas = 1;
          selector.matchLabels.app = "home-assistant";
          template = {
            metadata.labels.app = "home-assistant";
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
                  name = "home-assistant";
                  image = homeassistantImage;
                  imagePullPolicy = "IfNotPresent";
                  env = [
                    {
                      name = "TZ";
                      value = "America/Chicago";
                    }
                  ];
                  ports = [ { containerPort = homeassistantPort; } ];
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
      "home-assistant-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "home-assistant";
        };
        spec = {
          selector.app = "home-assistant";
          ports = [
            {
              port = homeassistantPort;
              targetPort = homeassistantPort;
            }
          ];
        };
      };
      "home-assistant-ingress.yaml".content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "home-assistant";
          # Same chains as the edge IngressRoutes (see k3s-traefik-middlewares.nix).
          annotations = {
            "traefik.ingress.kubernetes.io/router.middlewares" =
              middlewaresLib.ingressMiddlewareAnnotation homelab.home-assistant.services.home-assistant;
          };
        };
        spec = {
          ingressClassName = "traefik";
          tls = [
            {
              hosts = [ "home-assistant.diekvoss.net" ];
              secretName = "wildcard-tls-diekvoss-net";
            }
          ];
          rules = [
            {
              host = "home-assistant.diekvoss.net";
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "home-assistant";
                    port.number = homeassistantPort;
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
