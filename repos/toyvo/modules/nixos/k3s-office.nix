{
  config,
  lib,
  ...
}:
let
  cfg = config.nixcfg.k3sOffice;

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
                  securityContext = {
                    runAsUser = 0;
                  };
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
                    # Serve TLS itself (Traefik backends to :443): the DS builds
                    # absolute file URLs from the connection it sees, ignoring
                    # X-Forwarded-Proto, so plain-HTTP behind TLS terminates
                    # would emit http:// URLs forever. Uses the cluster
                    # wildcard cert (publicly trusted).
                    {
                      name = "SSL_CERTIFICATE_PATH";
                      value = "/tls/tls.crt";
                    }
                    {
                      name = "SSL_KEY_PATH";
                      value = "/tls/tls.key";
                    }
                    {
                      name = "TZ";
                      value = "America/Chicago";
                    }
                  ];
                  ports = [
                    { containerPort = officePort; }
                    {
                      name = "https";
                      containerPort = 443;
                    }
                  ];
                  # First boot does DB init + font/cache generation (minutes).
                  # Without initial delays the probes SIGKILL the pod mid-boot
                  # (exit 137 crashloop) before it can ever listen.
                  readinessProbe = {
                    httpGet = {
                      path = "/healthcheck";
                      port = 443;
                      scheme = "HTTPS";
                    };
                    initialDelaySeconds = 120;
                    periodSeconds = 30;
                  };
                  livenessProbe = {
                    httpGet = {
                      path = "/healthcheck";
                      port = 443;
                      scheme = "HTTPS";
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
                    {
                      name = "tls";
                      mountPath = "/tls";
                      readOnly = true;
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
                {
                  # Cluster wildcard cert so the DS can serve TLS itself.
                  name = "tls";
                  secret.secretName = "wildcard-tls-diekvoss-net";
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
              # Backend TLS: the DS serves https itself (see SSL_* env),
              # so Traefik dials 443 and everything the DS builds is
              # https-native. Plain :80 on the pod just redirects.
              name = "https";
              port = 443;
              targetPort = 443;
            }
          ];
        };
      };
      # IngressRoute (not Ingress): the only way to attach a
      # ServersTransport to the backend. The plain-Ingress
      # `service.serverstransport` annotation was silently ignored by
      # Traefik, which kept the default transport and failed IP-SAN
      # verification against the pod IP. Shape mirrors k3s-edge.nix.
      "euro-office-ingressroute.yaml".content = {
        apiVersion = "traefik.io/v1alpha1";
        kind = "IngressRoute";
        metadata = {
          name = "euro-office";
        };
        spec = {
          entryPoints = [ "websecure" ];
          routes = [
            {
              match = "Host(`office.diekvoss.net`)";
              kind = "Rule";
              # No forward-auth middleware: the Document Server authenticates
              # via its own JWT (gating it would break DS<->Nextcloud callbacks).
              # Local copies of the shared edge middlewares (see above): this
              # Traefik runs with allowCrossNamespace disabled, which rejects
              # cross-namespace refs entirely.
              middlewares = [
                { name = "euro-office-headers"; }
                { name = "euro-office-lanonly"; }
              ];
              services = [
                {
                  name = "euro-office";
                  port = 443;
                  serversTransport = "euro-office-transport";
                }
              ];
            }
          ];
          tls.secretName = "wildcard-tls-diekvoss-net";
        };
      };
      # Backend TLS transport: verify the DS's cert and SNI as the public
      # hostname (the mounted wildcard cert is publicly trusted, so no
      # insecureSkipVerify escape hatch needed). Referenced by name from
      # the IngressRoute above (same namespace).
      # Local copies of the shared edge middlewares: this Traefik
      # instance runs with allowCrossNamespace DISABLED, so the
      # cross-namespace refs (edge-NAME@kubernetescrd) that work for
      # annotation-based references are rejected here. Same semantics,
      # same namespace => plain short names resolve fine.
      "euro-office-mw-headers.yaml".content = {
        apiVersion = "traefik.io/v1alpha1";
        kind = "Middleware";
        metadata = {
          name = "euro-office-headers";
        };
        spec.headers = {
          customResponseHeaders.Server = "";
          forceSTSHeader = true;
          stsSeconds = 15552000;
          stsIncludeSubdomains = true;
          stsPreload = true;
        };
      };
      "euro-office-mw-lanonly.yaml".content = {
        apiVersion = "traefik.io/v1alpha1";
        kind = "Middleware";
        metadata = {
          name = "euro-office-lanonly";
        };
        spec.ipAllowList.sourceRange = [
          "127.0.0.0/8"
          "::1/128"
          "10.0.0.0/8"
          "172.16.0.0/12"
          "192.168.0.0/16"
          "fc00::/7"
        ];
      };
      "euro-office-transport.yaml".content = {
        apiVersion = "traefik.io/v1alpha1";
        kind = "ServersTransport";
        metadata = {
          name = "euro-office-transport";
          namespace = "default";
        };
        spec = {
          serverName = "office.diekvoss.net";
        };
      };
    };
  };
}
