{
  config,
  lib,
  homelab,
  ...
}:
let
  cfg = config.nixcfg.k3sHomepage;

  # Mirrors configurations/nixos/nas/homepage.nix (source of truth until
  # the nas-native service is retired). Differences from that file are
  # deliberate and marked RUNTIME below.
  homepageSettings = {
    background = "https://images.unsplash.com/photo-1507936580189-3816b4abf640?q=80&w=2400&auto=format&fit=crop";
    cardBlur = "md";
  };
  homepageBookmarks = [
    {
      Developer = [
        {
          Github = [
            {
              abbr = "GH";
              href = "https://github.com/";
            }
          ];
        }
      ];
    }
    {
      Social = [
        {
          Lemmy = [
            {
              abbr = "LM";
              href = "https://programming.dev/";
            }
          ];
        }
      ];
    }
    {
      Entertainment = [
        {
          YouTube = [
            {
              abbr = "YT";
              href = "https://youtube.com/";
            }
          ];
        }
      ];
    }
  ];
  homepageServices = lib.mapAttrsToList (category: services: { "${category}" = services; }) (
    lib.foldl' (
      acc: hostname:
      let
        services = homelab.${hostname}.services or { };
      in
      lib.foldl' (
        accInner: service:
        let
          displayName = services.${service}.displayName or service;
          subdomain = services.${service}.subdomain or service;
          domain = services.${service}.domain or "diekvoss.net";
          category = services.${service}.category or "TODO";
          description = services.${service}.description or "TODO";
          href = if subdomain == "@" then "https://${domain}" else "https://${subdomain}.${domain}";
        in
        accInner
        // {
          ${category} = (accInner.${category} or [ ]) ++ [
            {
              "${displayName}" = {
                inherit href description;
              }
              # RUNTIME: homepage.nix uses lib.mkIf here (resolved by the
              # nixpkgs option merger); mkIf values would render as garbage
              # through toYAML, so resolve the conditionals inline instead.
              // lib.optionalAttrs (lib.hasAttr "widget" services.${service}) {
                inherit (services.${service}) widget;
              }
              // lib.optionalAttrs (lib.hasAttr "icon" services.${service}) {
                inherit (services.${service}) icon;
              };
            }
          ];
        }
      ) acc (lib.attrNames services)
    ) { } (lib.attrNames homelab)
  );
  homepageWidgets = [
    {
      resources = {
        cpu = true;
        disk = "/";
        memory = true;
      };
    }
    {
      search = {
        provider = "duckduckgo";
        target = "_blank";
      };
    }
  ];

  toYAML = lib.generators.toYAML { };
  image = "ghcr.io/gethomepage/homepage:v2.6.0"; # matches nixpkgs homepage-dashboard 2.6.0
in
{
  options.nixcfg.k3sHomepage = {
    enable = lib.mkEnableOption "homepage-dashboard in k3s (first migration passenger)";
  };

  config = lib.mkIf cfg.enable {
    # The replication above was verified identical against the retired
    # nas-native service; this module (fed from homelab.nix) is now the
    # only source of truth.
    # One manifest per resource: k3s auto-deploy applies files as-is and
    # a wrapping `kind: List` is not safe for server-side apply.
    services.k3s.manifests."homepage-config.yaml".content = {
      apiVersion = "v1";
      kind = "ConfigMap";
      metadata = {
        name = "homepage-config";
      };
      data = {
        "settings.yaml" = toYAML homepageSettings;
        "bookmarks.yaml" = toYAML homepageBookmarks;
        "services.yaml" = toYAML homepageServices;
        "widgets.yaml" = toYAML homepageWidgets;
      };
    };
    services.k3s.manifests."homepage-deployment.yaml".content = {
      apiVersion = "apps/v1";
      kind = "Deployment";
      metadata = {
        name = "homepage";
        labels.app = "homepage";
      };
      spec = {
        replicas = 2;
        selector.matchLabels.app = "homepage";
        template = {
          metadata.labels.app = "homepage";
          spec = {
            containers = [
              {
                name = "homepage";
                inherit image;
                imagePullPolicy = "IfNotPresent";
                ports = [ { containerPort = 3000; } ];
                env = [
                  # RUNTIME: no probes — kubelet httpGet would send the pod
                  # IP as Host and trip allowedHosts. Revisit with a
                  # headers-aware probe later.
                  {
                    name = "HOMEPAGE_ALLOWED_HOSTS";
                    value = "diekvoss.net";
                  }
                ];
                # Widget API keys from Secret `homepage-widgets` (populated
                # via k8s/homepage/secretspec.toml). Same HOMEPAGE_VAR_*
                # names the native service used.
                envFrom = [
                  { secretRef.name = "homepage-widgets"; }
                ];
                resources = {
                  requests = {
                    cpu = "50m";
                    memory = "64Mi";
                  };
                  limits = {
                    cpu = "500m";
                    memory = "512Mi";
                  };
                };
                # RUNTIME: mount the four files individually, not the whole
                # directory. The ConfigMap volume is read-only and homepage
                # mkdirs /app/config/logs at runtime (EROFS → HTTP 500).
                # File mounts leave the image's own /app/config writable.
                volumeMounts = [
                  {
                    name = "config";
                    mountPath = "/app/config/settings.yaml";
                    subPath = "settings.yaml";
                  }
                  {
                    name = "config";
                    mountPath = "/app/config/bookmarks.yaml";
                    subPath = "bookmarks.yaml";
                  }
                  {
                    name = "config";
                    mountPath = "/app/config/services.yaml";
                    subPath = "services.yaml";
                  }
                  {
                    name = "config";
                    mountPath = "/app/config/widgets.yaml";
                    subPath = "widgets.yaml";
                  }
                ];
              }
            ];
            volumes = [
              {
                name = "config";
                configMap.name = "homepage-config";
              }
            ];
          };
        };
      };
    };
    services.k3s.manifests."homepage-service.yaml".content = {
      apiVersion = "v1";
      kind = "Service";
      metadata = {
        name = "homepage";
      };
      spec = {
        selector.app = "homepage";
        ports = [
          {
            port = 3000;
            targetPort = 3000;
          }
        ];
      };
    };
    services.k3s.manifests."homepage-ingress.yaml".content = {
      apiVersion = "networking.k8s.io/v1";
      kind = "Ingress";
      metadata = {
        name = "homepage";
      };
      spec = {
        ingressClassName = "traefik";
        rules = [
          {
            host = "diekvoss.net";
            http.paths = [
              {
                path = "/";
                pathType = "Prefix";
                backend.service = {
                  name = "homepage";
                  port.number = 3000;
                };
              }
            ];
          }
        ];
      };
    };
  };
}
