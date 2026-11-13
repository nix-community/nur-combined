{
  config,
  homelab,
  lib,
  ...
}:
let
  cfg = config.nixcfg.k3sEdge;
  edgeNamespace = "edge";
  middlewaresLib = import ./k3s-traefik-middlewares.nix { inherit lib; };

  sanitize = s: lib.toLower (builtins.replaceStrings [ "." "_" "@" ] [ "-" "-" "" ] s);

  # Same host filter Caddy used: only 10.1.0./10.200. hosts get edge routes.
  edgeHosts = lib.filterAttrs (
    _:
    {
      ip ? "",
      ...
    }:
    lib.hasPrefix "10.1.0." ip || lib.hasPrefix "10.200." ip
  ) homelab;

  # Flattened list of routable services. Services with `upstreams` are
  # served by their in-cluster Ingress already and get no LAN route.
  routes = lib.flatten (
    lib.mapAttrsToList (
      hostName:
      {
        ip,
        services ? { },
        ...
      }:
      lib.mapAttrsToList (
        serviceName:
        {
          port,
          subdomain ? serviceName,
          domain ? "diekvoss.net",
          selfSigned ? false,
          public ? domain != "diekvoss.net",
          forwardAuthGate ? true,
          upstreams ? null,
          ...
        }:
        {
          key = "${sanitize hostName}-${sanitize serviceName}";
          vhost = if subdomain == "@" then domain else "${subdomain}.${domain}";
          inherit
            hostName
            ip
            serviceName
            port
            domain
            selfSigned
            public
            forwardAuthGate
            upstreams
            ;
        }
      ) (lib.filterAttrs (_: svc: (svc.upstreams or null) == null) services)
    ) edgeHosts
  );

  routeManifests = lib.listToAttrs (
    lib.concatMap (
      r:
      let
        svcName = "edge-${r.key}";
        # Same-namespace short refs; selection logic lives in
        # k3s-traefik-middlewares.nix (shared with the Ingress generators).
        middlewares = map (name: { inherit name; }) (
          middlewaresLib.routerMiddlewareNames {
            inherit (r)
              domain
              public
              forwardAuthGate
              selfSigned
              ;
          }
        );
        backend = {
          name = svcName;
          port = r.port;
        }
        // lib.optionalAttrs r.selfSigned {
          serversTransport = "edge-insecure-${r.key}";
        };
      in
      [
        {
          name = "${svcName}-svc.yaml";
          value.content = {
            apiVersion = "v1";
            kind = "Service";
            metadata = {
              name = svcName;
              namespace = edgeNamespace;
            };
            spec.ports = [
              {
                port = r.port;
                targetPort = r.port;
                protocol = "TCP";
              }
            ];
          };
        }
        {
          name = "${svcName}-eps.yaml";
          value.content = {
            apiVersion = "v1";
            kind = "Endpoints";
            metadata = {
              name = svcName;
              namespace = edgeNamespace;
            };
            subsets = [
              {
                addresses = [ { ip = r.ip; } ];
                ports = [
                  {
                    port = r.port;
                    protocol = "TCP";
                  }
                ];
              }
            ];
          };
        }
        {
          name = "${svcName}-route.yaml";
          value.content = {
            apiVersion = "traefik.io/v1alpha1";
            kind = "IngressRoute";
            metadata = {
              name = svcName;
              namespace = edgeNamespace;
            };
            spec = {
              entryPoints = [ "websecure" ];
              routes = [
                {
                  match = "Host(`${r.vhost}`)";
                  kind = "Rule";
                  inherit middlewares;
                  services = [ backend ];
                }
              ];
              tls.secretName = "wildcard-tls-${lib.replaceStrings [ "." ] [ "-" ] r.domain}";
            };
          };
        }
      ]
      ++ lib.optional r.selfSigned {
        name = "${svcName}-transport.yaml";
        value.content = {
          apiVersion = "traefik.io/v1alpha1";
          kind = "ServersTransport";
          metadata = {
            name = "edge-insecure-${r.key}";
            namespace = edgeNamespace;
          };
          spec.insecureSkipVerify = true;
        };
      }
    ) routes
  );
in
{
  options.nixcfg.k3sEdge = {
    enable = lib.mkEnableOption "Traefik edge routes generated from homelab";
  };

  config = lib.mkIf cfg.enable {
    services.k3s.manifests = {
      "edge-namespace.yaml".content = {
        apiVersion = "v1";
        kind = "Namespace";
        metadata.name = edgeNamespace;
      };
      "edge-mw-auth.yaml".content = {
        apiVersion = "traefik.io/v1alpha1";
        kind = "Middleware";
        metadata = {
          name = "edge-authentik-forwardauth";
          namespace = edgeNamespace;
        };
        spec.forwardAuth = {
          address = "http://${homelab.authentik.ip}:9000/outpost.goauthentik.io/auth/traefik";
          authResponseHeaders = [
            "X-Authentik-Username"
            "X-Authentik-Groups"
            "X-Authentik-Jwt"
            "X-Authentik-Email"
            "X-Authentik-Name"
            "X-Authentik-Uid"
            "X-Authentik-Session-Issuer"
          ];
          authRequestHeaders = [
            "X-Forwarded-Method"
            "X-Forwarded-Proto"
            "X-Forwarded-Host"
            "X-Forwarded-Uri"
            "X-Forwarded-For"
          ];
        };
      };
      "edge-mw-lanonly.yaml".content = {
        apiVersion = "traefik.io/v1alpha1";
        kind = "Middleware";
        metadata = {
          name = "edge-lan-only";
          namespace = edgeNamespace;
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
      "edge-mw-headers.yaml".content = {
        apiVersion = "traefik.io/v1alpha1";
        kind = "Middleware";
        metadata = {
          name = "edge-secure-headers";
          namespace = edgeNamespace;
        };
        spec.headers = {
          customResponseHeaders.Server = "";
          forceSTSHeader = true;
          stsSeconds = 15552000;
          stsIncludeSubdomains = true;
          stsPreload = true;
        };
      };
    }
    // routeManifests;
  };
}
