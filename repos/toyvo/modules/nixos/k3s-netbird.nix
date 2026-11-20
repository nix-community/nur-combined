{
  config,
  lib,
  ...
}:
let
  cfg = config.nixcfg.k3sNetbird;
  middlewaresLib = import ./k3s-traefik-middlewares.nix { inherit lib; };

  # Pinned at upstream stable (verified 2026-11-18, Task 1).
  # Dashboard versions independently (v2.x line) — see Task 1 brief.
  managementImage = "netbirdio/management:0.82.0";
  signalImage = "netbirdio/signal:0.82.0";
  relayImage = "netbirdio/relay:0.82.0";
  dashboardImage = "netbirdio/dashboard:v2.97.0";

  managementPort = 33073;
  signalPort = 80;
  relayPort = 33080;
  dashboardPort = 80;
  relayNodePort = 33080;

  # Public vhosts (toyvo.dev is internet-facing; diekvoss.net is LAN-only).
  # DNS (Cloudflare, manual) + home-router UDP forward for the relay are
  # user steps at Task 4 — the manifests assume they exist.
  dashboardHost = "netbird.diekvoss.net";
  managementHost = "netbird-mgmt.toyvo.dev";
  signalHost = "netbird-signal.toyvo.dev";
  relayHost = "relay.toyvo.dev";

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

  secretName = "netbird-secrets";

  # Management config template: secret values ($VAR) are substituted at
  # container start by the envsubst init-container (values come from the
  # Secret as env — never baked into the ConfigMap or the Nix store).
  managementJsonTmpl = ''
    {
        "Stuns": [],
        "TURNConfig": {
            "Turns": [],
            "CredentialsTTL": "12h",
            "Secret": "unused-relay-only",
            "TimeBasedCredentials": false
        },
        "Relay": {
            "Addresses": ["rel://${relayHost}:${toString relayPort}"],
            "CredentialsTTL": "24h",
            "Secret": "$NETBIRD_RELAY_AUTH_SECRET"
        },
        "Signal": {
            "Proto": "http",
            "URI": "${signalHost}:443",
            "Username": "",
            "Password": null
        },
        "ReverseProxy": {
            "TrustedHTTPProxies": [],
            "TrustedHTTPProxiesCount": 0,
            "TrustedPeers": []
        },
        "DisableDefaultPolicy": false,
        "Datadir": "/var/lib/netbird",
        "DataStoreEncryptionKey": "$NETBIRD_DATASTORE_ENC_KEY",
        "StoreConfig": {
            "Engine": "sqlite"
        },
        "HttpConfig": {
            "Address": "0.0.0.0:${toString managementPort}",
            "AuthIssuer": "$NETBIRD_AUTH_AUTHORITY",
            "AuthAudience": "$NETBIRD_AUTH_AUDIENCE",
            "AuthKeysLocation": "$NETBIRD_AUTH_JWT_CERTS",
            "AuthUserIDClaim": "sub",
            "CertFile": "",
            "CertKey": "",
            "IdpSignKeyRefreshEnabled": false,
            "OIDCConfigEndpoint": "$NETBIRD_AUTH_OIDC_CONFIGURATION_ENDPOINT"
        },
        "IdpManagerConfig": {
            "ManagerType": "none",
            "ClientConfig": {
                "Issuer": "$NETBIRD_AUTH_AUTHORITY",
                "TokenEndpoint": "$NETBIRD_AUTH_TOKEN_ENDPOINT",
                "ClientID": "$NETBIRD_AUTH_CLIENT_ID",
                "ClientSecret": "$NETBIRD_AUTH_CLIENT_SECRET",
                "GrantType": "client_credentials"
            },
            "ExtraConfig": {}
        },
        "DeviceAuthorizationFlow": {
            "Provider": "hosted",
            "ProviderConfig": {
                "Domain": "${dashboardHost}",
                "ClientID": "$NETBIRD_AUTH_CLIENT_ID",
                "ClientSecret": "$NETBIRD_AUTH_CLIENT_SECRET",
                "TokenEndpoint": "$NETBIRD_AUTH_TOKEN_ENDPOINT",
                "DeviceAuthEndpoint": "$NETBIRD_AUTH_DEVICE_ENDPOINT",
                "Scope": "openid profile email offline_access",
                "UseIDToken": false
            }
        }
    }
  '';
in
{
  options.nixcfg.k3sNetbird = {
    enable = lib.mkEnableOption "NetBird control plane (management + signal + relay + dashboard) in k3s";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.nixcfg.k3s.enable && config.nixcfg.k3s.role == "server";
        message = "nixcfg.k3sNetbird: manifests must live on a server (nas), never an agent.";
      }
    ];

    services.k3s.manifests = {
      "netbird-management-pvc.yaml".content = {
        apiVersion = "v1";
        kind = "PersistentVolumeClaim";
        metadata = {
          name = "netbird-management";
        };
        spec = {
          accessModes = [ "ReadWriteOnce" ];
          resources.requests.storage = "5Gi";
        };
      };
      # Template (secret $VARS substituted at start) + rendered config
      # (emptyDir shared between the init container and the app).
      "netbird-management-config.yaml".content = {
        apiVersion = "v1";
        kind = "ConfigMap";
        metadata = {
          name = "netbird-management-config";
        };
        data = {
          "management.json.tmpl" = managementJsonTmpl;
        };
      };
      "netbird-management.yaml".content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "netbird-management";
          labels.app = "netbird-management";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "netbird-management";
          template = {
            metadata.labels.app = "netbird-management";
            spec = {
              affinity.nodeAffinity = nodeAffinity;
              # Renders management.json from the template + Secret env.
              # Secrets never touch the ConfigMap or the Nix store.
              initContainers = [
                {
                  name = "render-config";
                  # busybox lacks envsubst (gettext); python does safe
                  # $-substitution (string.Template) with no sed-escaping
                  # hazards for arbitrary secret chars.
                  image = "python:3.14-slim";
                  imagePullPolicy = "IfNotPresent";
                  command = [
                    "python3"
                    "-c"
                    "import os,string,pathlib; t = pathlib.Path('/tmpl/management.json.tmpl').read_text(); out = string.Template(t).safe_substitute(os.environ); pathlib.Path('/etc/netbird/management.json').write_text(out); os.chmod('/etc/netbird/management.json', 0o640)"
                  ];
                  env = [
                    {
                      name = "NETBIRD_RELAY_AUTH_SECRET";
                      valueFrom.secretKeyRef = {
                        name = secretName;
                        key = "relay-auth-secret";
                      };
                    }
                    {
                      name = "NETBIRD_DATASTORE_ENC_KEY";
                      valueFrom.secretKeyRef = {
                        name = secretName;
                        key = "datastore-enc-key";
                      };
                    }
                    {
                      name = "NETBIRD_AUTH_AUTHORITY";
                      value = "https://auth.diekvoss.net/application/o/netbird/";
                    }
                    {
                      name = "NETBIRD_AUTH_AUDIENCE";
                      valueFrom.secretKeyRef = {
                        name = secretName;
                        key = "auth-audience";
                      };
                    }
                    {
                      name = "NETBIRD_AUTH_JWT_CERTS";
                      value = "https://auth.diekvoss.net/application/o/netbird/jwks/";
                    }
                    {
                      name = "NETBIRD_AUTH_OIDC_CONFIGURATION_ENDPOINT";
                      value = "https://auth.diekvoss.net/application/o/netbird/.well-known/openid-configuration";
                    }
                    {
                      name = "NETBIRD_AUTH_TOKEN_ENDPOINT";
                      value = "https://auth.diekvoss.net/application/o/token/";
                    }
                    {
                      name = "NETBIRD_AUTH_DEVICE_ENDPOINT";
                      value = "https://auth.diekvoss.net/application/o/device/";
                    }
                    {
                      name = "NETBIRD_AUTH_CLIENT_ID";
                      valueFrom.secretKeyRef = {
                        name = secretName;
                        key = "auth-client-id";
                      };
                    }
                    {
                      name = "NETBIRD_AUTH_CLIENT_SECRET";
                      valueFrom.secretKeyRef = {
                        name = secretName;
                        key = "auth-client-secret";
                      };
                    }
                  ];
                  volumeMounts = [
                    {
                      name = "config-tmpl";
                      mountPath = "/tmpl";
                      readOnly = true;
                    }
                    {
                      name = "config";
                      mountPath = "/etc/netbird";
                    }
                  ];
                }
              ];
              containers = [
                {
                  name = "management";
                  image = managementImage;
                  imagePullPolicy = "IfNotPresent";
                  args = [
                    "--port"
                    (toString managementPort)
                    "--log-file"
                    "console"
                    "--log-level"
                    "info"
                    "--disable-anonymous-metrics=true"
                    "--single-account-mode-domain=netbird.selfhosted"
                    "--dns-domain=netbird.selfhosted"
                  ];
                  ports = [ { containerPort = managementPort; } ];
                  # No documented HTTP health endpoint — TCP aliveness only
                  # (readiness gates traffic, same as loki).
                  readinessProbe = {
                    tcpSocket.port = managementPort;
                    initialDelaySeconds = 60;
                    periodSeconds = 30;
                  };
                  livenessProbe = {
                    tcpSocket.port = managementPort;
                    initialDelaySeconds = 120;
                    periodSeconds = 60;
                  };
                  volumeMounts = [
                    {
                      name = "data";
                      mountPath = "/var/lib/netbird";
                    }
                    {
                      name = "config";
                      mountPath = "/etc/netbird";
                      readOnly = true;
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "data";
                  persistentVolumeClaim.claimName = "netbird-management";
                }
                {
                  name = "config-tmpl";
                  configMap.name = "netbird-management-config";
                }
                {
                  name = "config";
                  emptyDir = { };
                }
              ];
            };
          };
        };
      };
      "netbird-management-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "netbird-management";
        };
        spec = {
          selector.app = "netbird-management";
          ports = [
            {
              port = managementPort;
              targetPort = managementPort;
            }
          ];
        };
      };
      # Public: off-LAN agents call the management API (setup keys, no
      # browser session) — forward-auth would break them, stays OFF.
      "netbird-management-ingress.yaml".content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "netbird-management";
          annotations = {
            "traefik.ingress.kubernetes.io/router.middlewares" = middlewaresLib.ingressMiddlewareAnnotation {
              domain = "toyvo.dev";
              public = true;
              forwardAuthGate = false;
            };
            "traefik.ingress.kubernetes.io/service.serversscheme" = "h2c";
          };
        };
        spec = {
          ingressClassName = "traefik";
          tls = [
            {
              hosts = [ managementHost ];
              secretName = "wildcard-tls-toyvo-dev";
            }
          ];
          rules = [
            {
              host = managementHost;
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "netbird-management";
                    port.number = managementPort;
                  };
                }
              ];
            }
          ];
        };
      };
      "netbird-signal.yaml".content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "netbird-signal";
          labels.app = "netbird-signal";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "netbird-signal";
          template = {
            metadata.labels.app = "netbird-signal";
            spec = {
              affinity.nodeAffinity = nodeAffinity;
              containers = [
                {
                  name = "signal";
                  image = signalImage;
                  imagePullPolicy = "IfNotPresent";
                  args = [
                    "--port"
                    (toString signalPort)
                    "--log-file"
                    "console"
                  ];
                  ports = [ { containerPort = signalPort; } ];
                  readinessProbe = {
                    tcpSocket.port = signalPort;
                    initialDelaySeconds = 30;
                    periodSeconds = 10;
                  };
                  volumeMounts = [
                    {
                      name = "data";
                      mountPath = "/var/lib/netbird";
                    }
                  ];
                }
              ];
              volumes = [
                {
                  name = "data";
                  emptyDir = { };
                }
              ];
            };
          };
        };
      };
      "netbird-signal-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "netbird-signal";
        };
        spec = {
          selector.app = "netbird-signal";
          ports = [
            {
              port = signalPort;
              targetPort = signalPort;
            }
          ];
        };
      };
      # Public WS for off-LAN agents (same no-gate reasoning as management).
      "netbird-signal-ingress.yaml".content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "netbird-signal";
          annotations = {
            "traefik.ingress.kubernetes.io/router.middlewares" = middlewaresLib.ingressMiddlewareAnnotation {
              domain = "toyvo.dev";
              public = true;
              forwardAuthGate = false;
            };
          };
        };
        spec = {
          ingressClassName = "traefik";
          tls = [
            {
              hosts = [ signalHost ];
              secretName = "wildcard-tls-toyvo-dev";
            }
          ];
          rules = [
            {
              host = signalHost;
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "netbird-signal";
                    port.number = signalPort;
                  };
                }
              ];
            }
          ];
        };
      };
      "netbird-relay.yaml".content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "netbird-relay";
          labels.app = "netbird-relay";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "netbird-relay";
          template = {
            metadata.labels.app = "netbird-relay";
            spec = {
              affinity.nodeAffinity = nodeAffinity;
              containers = [
                {
                  name = "relay";
                  image = relayImage;
                  imagePullPolicy = "IfNotPresent";
                  env = [
                    {
                      name = "NB_LOG_LEVEL";
                      value = "info";
                    }
                    {
                      name = "NB_LISTEN_ADDRESS";
                      value = ":${toString relayPort}";
                    }
                    {
                      name = "NB_EXPOSED_ADDRESS";
                      value = "rel://${relayHost}:${toString relayPort}";
                    }
                    {
                      name = "NB_AUTH_SECRET";
                      valueFrom.secretKeyRef = {
                        name = secretName;
                        key = "relay-auth-secret";
                      };
                    }
                  ];
                  ports = [
                    {
                      containerPort = relayPort;
                      protocol = "UDP";
                    }
                  ];
                  readinessProbe = {
                    tcpSocket.port = relayPort;
                    initialDelaySeconds = 30;
                    periodSeconds = 10;
                  };
                }
              ];
            };
          };
        };
      };
      # Raw UDP for NAT traversal (rel://). Traefik can't do it without
      # TCP/UDP route config — NodePort + home-router forward (user step),
      # same split as game servers and Loki ingest before it.
      "netbird-relay-nodeport.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "netbird-relay";
        };
        spec = {
          type = "NodePort";
          selector.app = "netbird-relay";
          ports = [
            {
              port = relayPort;
              targetPort = relayPort;
              nodePort = relayNodePort;
              protocol = "UDP";
            }
          ];
        };
      };
      "netbird-dashboard.yaml".content = {
        apiVersion = "apps/v1";
        kind = "Deployment";
        metadata = {
          name = "netbird-dashboard";
          labels.app = "netbird-dashboard";
        };
        spec = {
          replicas = 1;
          selector.matchLabels.app = "netbird-dashboard";
          template = {
            metadata.labels.app = "netbird-dashboard";
            spec = {
              affinity.nodeAffinity = nodeAffinity;
              containers = [
                {
                  name = "dashboard";
                  image = dashboardImage;
                  imagePullPolicy = "IfNotPresent";
                  env = [
                    {
                      # Public URL, no explicit port: Traefik terminates :443
                      # and routes to the ClusterIP internally. Including the
                      # backend port here (e.g. :33073) makes browsers try it
                      # directly against Traefik/CF, where nothing listens.
                      name = "NETBIRD_MGMT_API_ENDPOINT";
                      value = "https://${managementHost}";
                    }
                    {
                      name = "NETBIRD_MGMT_GRPC_API_ENDPOINT";
                      value = "https://${managementHost}";
                    }
                    {
                      name = "AUTH_AUDIENCE";
                      valueFrom.secretKeyRef = {
                        name = secretName;
                        key = "auth-audience";
                      };
                    }
                    {
                      name = "AUTH_CLIENT_ID";
                      valueFrom.secretKeyRef = {
                        name = secretName;
                        key = "auth-client-id";
                      };
                    }
                    {
                      name = "AUTH_CLIENT_SECRET";
                      valueFrom.secretKeyRef = {
                        name = secretName;
                        key = "auth-client-secret";
                      };
                    }
                    {
                      name = "AUTH_AUTHORITY";
                      value = "https://auth.diekvoss.net/application/o/netbird/";
                    }
                    {
                      name = "USE_AUTH0";
                      value = "false";
                    }
                    {
                      name = "AUTH_SUPPORTED_SCOPES";
                      value = "openid profile email offline_access";
                    }
                    {
                      # Paths, not full URLs: the dashboard prepends the
                      # browser origin itself (absolute URLs double up:
                      # https://hosthttps://host/ — seen live 2026-11-19).
                      name = "AUTH_REDIRECT_URI";
                      value = "/";
                    }
                    {
                      name = "AUTH_SILENT_REDIRECT_URI";
                      value = "/silent-callback";
                    }
                    {
                      name = "NETBIRD_TOKEN_SOURCE";
                      value = "idToken";
                    }
                    {
                      name = "NGINX_SSL_PORT";
                      value = "443";
                    }
                  ];
                  ports = [ { containerPort = dashboardPort; } ];
                  readinessProbe = {
                    httpGet = {
                      path = "/";
                      port = dashboardPort;
                    };
                    initialDelaySeconds = 30;
                    periodSeconds = 10;
                  };
                }
              ];
            };
          };
        };
      };
      "netbird-dashboard-service.yaml".content = {
        apiVersion = "v1";
        kind = "Service";
        metadata = {
          name = "netbird-dashboard";
        };
        spec = {
          selector.app = "netbird-dashboard";
          ports = [
            {
              port = dashboardPort;
              targetPort = dashboardPort;
            }
          ];
        };
      };
      # Admin UI: LAN-only + forward-auth ON (double gate with OIDC —
      # same posture as Grafana).
      "netbird-dashboard-ingress.yaml".content = {
        apiVersion = "networking.k8s.io/v1";
        kind = "Ingress";
        metadata = {
          name = "netbird-dashboard";
          annotations = {
            "traefik.ingress.kubernetes.io/router.middlewares" = middlewaresLib.ingressMiddlewareAnnotation {
              domain = "diekvoss.net";
              public = false;
              forwardAuthGate = true;
            };
          };
        };
        spec = {
          ingressClassName = "traefik";
          tls = [
            {
              hosts = [ dashboardHost ];
              secretName = "wildcard-tls-diekvoss-net";
            }
          ];
          rules = [
            {
              host = dashboardHost;
              http.paths = [
                {
                  path = "/";
                  pathType = "Prefix";
                  backend.service = {
                    name = "netbird-dashboard";
                    port.number = dashboardPort;
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
