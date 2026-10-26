{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.realm.observability;
  hostName = config.networking.hostName;
  endpoints = lib.filterAttrs (_: e: e.enable) cfg.endpoints;
  workload = config.realm.workloads.observability;
  # One identity per process: the observation gateway keeps its own SVID so a
  # compromise of the public gateway cannot impersonate it.
  spiffeID = "${config.realm.servicePrefix}observability-${hostName}";
  # Stand-in TLS server name. Callers reach the mesh address directly and send
  # no SNI, so the connection policy supplies this name and the SPIFFE
  # certificate manager answers with the workload SVID.
  certSubject = "observability-${hostName}";
  # Public path per endpoint. Probe endpoints additionally require the exact
  # module/target pair, so only enumerated checks can be run.
  publicPath = name: e: "/${name}/${if e.kind == "probe" then "probe" else "metrics"}";
  denied = {
    handler = "static_response";
    status_code = 403;
  };
  # Upstream exporters expect their loopback name, not the mesh host name.
  proxy = e: {
    handler = "reverse_proxy";
    upstreams = [
      (
        if e.socket != null then
          { dial = "unix/${e.socket}"; }
        else
          { dial = "${e.address}:${toString e.port}"; }
      )
    ];
    headers.request.set.Host = [ "localhost" ];
  };
  # The endpoint path is the whole policy: a metrics endpoint accepts no query
  # at all, and a probe endpoint accepts exactly one enumerated module/target
  # pair, in either order and with no further parameters. The parameter count
  # is checked on the raw query, because the query matcher ignores parameters
  # it was not told about and resolves repeated keys leniently.
  exactlyTwoParameters = {
    expression = "{http.request.uri.query}.matches(\"^[^&=]+=[^&]*&[^&=]+=[^&]*$\")";
  };
  endpointRoutes =
    name: e:
    (
      if e.kind == "metrics" then
        [
          {
            match = [
              {
                path = [ (publicPath name e) ];
                method = [ "GET" ];
                expression = "{http.request.uri.query} == \"\"";
              }
            ];
            handle = [
              {
                handler = "rewrite";
                uri = e.path;
              }
              (proxy e)
            ];
          }
        ]
      else
        map (p: {
          match = [
            (
              {
                path = [ (publicPath name e) ];
                method = [ "GET" ];
                query = {
                  module = [ p.module ];
                  target = [ p.target ];
                };
              }
              // exactlyTwoParameters
            )
          ];
          handle = [
            {
              handler = "rewrite";
              uri = e.path;
            }
            (proxy e)
          ];
        }) e.probes
    );
  # Path normalization is part of the policy: the allowlist above matches the
  # normalized path, so escaped or repeated slashes and dot segments must not be
  # able to alias a protected path. Escaped slashes are a client error, as they
  # were under the previous gateway; the rest are refused.
  #
  # Only the path is checked. A query legitimately carries percent-encoded
  # values — a probe target is sent as `https%3A%2F%2F…` — and rejecting those
  # would refuse every URL probe.
  escapedSlashGuard = {
    match = [
      {
        expression = "{http.request.uri}.matches(\"^[^?]*(%2f|%2F)\")";
      }
    ];
    handle = [
      {
        handler = "static_response";
        status_code = 400;
      }
    ];
  };
  pathGuard = {
    match = [
      {
        expression = "{http.request.uri.path}.contains(\"//\") || {http.request.uri.path}.contains(\"/../\") || {http.request.uri.path}.endsWith(\"/..\")";
      }
    ];
    handle = [ denied ];
  };
  # Paths a business or public listener must never expose, even though all
  # other traffic there is forwarded verbatim.
  # Path policy for listeners that forward everything else verbatim.
  forwardedRoutes = e: [
    escapedSlashGuard
    pathGuard
    {
      match = [
        {
          path = lib.unique [
            "/metrics"
            "/metrics/*"
            "/debug"
            "/debug/*"
            e.path
            "${e.path}/*"
          ];
        }
      ];
      handle = [ denied ];
    }
    { handle = [ (proxy e) ]; }
  ];
  # mTLS for callers: client certificate required and verified against the
  # SPIRE bundle, TLS 1.3 only, SVID served by the get_certificate module.
  mtls = ids: {
    automatic_https.disable = true;
    # With client authentication Caddy otherwise requires the request Host to
    # match the TLS SNI. Callers reach this listener through a local adapter and
    # keep their own Host, and authorization is the client identity below.
    strict_sni_host = false;
    tls_connection_policies = [
      {
        default_sni = certSubject;
        protocol_min = "tls1.3";
        client_authentication = {
          mode = "require";
          verifiers = [
            {
              verifier = "spiffe";
              socket_path = config.realm.spire.socket;
              allowed_ids = ids;
            }
          ];
        };
      }
    ];
  };
  address = "[${config.realm.address}]";
  # Exporters binding loopback are still reachable through the host's mesh
  # address, so the module blocks them at the firewall. A port that a public
  # listener already re-exposes is skipped, because that forwarding is
  # deliberate.
  protectedPorts = lib.unique (
    map (e: e.port) (
      builtins.attrValues (
        lib.filterAttrs (
          _: e:
          e.port != null
          && builtins.elem e.address [
            "127.0.0.1"
            "::1"
          ]
          && e.publicProxyPort != e.port
        ) endpoints
      )
    )
  );
  # Called by path so the gateway also evaluates without this flake's overlay.
  caddy = pkgs.callPackage ../pkgs/by-name/caddy-realm.nix { };
  format = pkgs.formats.json { };
  configfile = format.generate "realm-observability.json" {
    admin.disabled = true;
    apps = {
      tls.automation.policies = [
        # No subject list on purpose: a policy only applies to a connection whose
        # SNI it matches, and callers dial a mesh address, so the ClientHello
        # carries no server name at all. An unfiltered policy is the only one
        # that answers it; default_sni then names the certificate to serve.
        {
          get_certificate = [
            {
              via = "spiffe";
              socket_path = config.realm.spire.socket;
              spiffe_id = spiffeID;
            }
          ];
        }
      ];
      http.servers = {
        observation = mtls cfg.allowedIDs // {
          listen = [ "${address}:${toString cfg.port}" ];
          routes = [
            escapedSlashGuard
            pathGuard
          ]
          ++ lib.concatLists (lib.mapAttrsToList endpointRoutes endpoints)
          ++ [ { handle = [ denied ]; } ];
        };
      }
      // lib.mapAttrs' (
        name: e:
        lib.nameValuePair "business-${name}" (
          mtls e.businessAllowedIDs
          // {
            listen = [ "${address}:${toString e.businessProxyPort}" ];
            routes = forwardedRoutes e;
          }
        )
      ) (lib.filterAttrs (_: e: e.businessProxyPort != null) endpoints)
      // lib.mapAttrs' (
        name: e:
        lib.nameValuePair "public-${name}" {
          listen = [ "${address}:${toString e.publicProxyPort}" ];
          automatic_https.disable = true;
          routes = forwardedRoutes e;
        }
      ) (lib.filterAttrs (_: e: e.publicProxyPort != null) endpoints);
    };
  };
in
{
  options.realm.observability = {
    enable = lib.mkEnableOption "SPIFFE authenticated, path-restricted observation endpoints";
    port = lib.mkOption {
      type = lib.types.port;
      default = 19490;
    };
    allowedIDs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "${config.realm.servicePrefix}vmagent" ];
      description = "SPIFFE IDs accepted by the observation listener.";
    };
    # One entry per exporter that should be reachable from the mesh. The
    # attribute name becomes the public path, so `garage` is reachable as
    # /garage/metrics.
    endpoints = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, ... }:
          {
            options = {
              enable = lib.mkOption {
                type = lib.types.bool;
                default = true;
              };
              address = lib.mkOption {
                type = lib.types.str;
                default = "127.0.0.1";
              };
              port = lib.mkOption {
                type = lib.types.nullOr lib.types.port;
                default = null;
              };
              socket = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              path = lib.mkOption {
                type = lib.types.str;
                default = "/metrics";
              };
              kind = lib.mkOption {
                type = lib.types.enum [
                  "metrics"
                  "probe"
                ];
                default = "metrics";
              };
              probes = lib.mkOption {
                type = lib.types.listOf (
                  lib.types.submodule {
                    options = {
                      module = lib.mkOption { type = lib.types.str; };
                      target = lib.mkOption { type = lib.types.str; };
                    };
                  }
                );
                default = [ ];
              };
              publicProxyPort = lib.mkOption {
                type = lib.types.nullOr lib.types.port;
                default = null;
                description = "Preserve a shared business HTTP port while denying metrics and debug paths there.";
              };
              businessProxyPort = lib.mkOption {
                type = lib.types.nullOr lib.types.port;
                default = null;
                description = "Additional mTLS business API listener with an explicit caller allowlist, excluding metrics and debug paths.";
              };
              businessAllowedIDs = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
                description = "SPIFFE IDs permitted to use businessProxyPort.";
              };
              businessService = lib.mkOption {
                type = lib.types.str;
                default = "${name}-${config.networking.hostName}";
                description = "DNS service name that advertises businessProxyPort for SRV discovery.";
              };
            };
          }
        )
      );
    };
  };
  config = lib.mkIf cfg.enable {
    networking.nftables = {
      enable = true;
      # Defence in depth for exporters that apply no authentication of their own.
      tables.realm-observability = lib.mkIf (protectedPorts != [ ]) {
        family = "inet";
        content = ''
          chain input {
            type filter hook input priority -5; policy accept;
            iifname != "lo" tcp dport { ${lib.concatMapStringsSep ", " toString protectedPorts} } drop
          }
        '';
      };
    };
    assertions = lib.mapAttrsToList (name: e: {
      assertion =
        builtins.match "[a-z][a-z0-9-]*" name != null
        && ((e.port == null) != (e.socket == null))
        && (e.kind != "probe" || e.probes != [ ])
        && (e.publicProxyPort == null || e.kind == "metrics")
        && (
          e.businessProxyPort == null
          || (
            e.kind == "metrics"
            && e.businessAllowedIDs != [ ]
            && e.businessProxyPort != e.port
            && e.businessProxyPort != e.publicProxyPort
          )
        );
      message = "realm.observability.endpoints.${name}: declare one backend and an explicit probe allowlist.";
    }) endpoints;
    environment.etc."realm-observability/config.json".source = configfile;
    # Caddy replaces Envoy here because the same plugin set already ships in
    # caddy-realm: the SVID and the trust bundle come from the Workload API, so
    # no certificate files exist on disk and renewal needs no reload.
    #
    # The gateway keeps a separate process from the public Caddy instance on
    # purpose: one process holds one SPIFFE identity, and this one is authorized
    # only for observations.
    systemd.services.realm-observability = {
      wantedBy = [ "multi-user.target" ];
      # The admin endpoint is disabled, so Caddy cannot be reloaded in place: a
      # changed configuration restarts the unit instead of being silently
      # ignored until the next reboot.
      restartTriggers = [ configfile ];
      requires = [ "spire-agent.service" ];
      # Keep the gateway lifecycle tied to the local Agent.
      partOf = [ "spire-agent.service" ];
      after = [
        "network.target"
        "spire-agent.service"
      ];
      serviceConfig = {
        Type = "notify";
        User = workload.user;
        Group = workload.group;
        ExecStartPre = "${caddy}/bin/caddy validate --config /etc/realm-observability/config.json";
        ExecStart = "${caddy}/bin/caddy run --config /etc/realm-observability/config.json";
        Restart = "on-failure";
        RestartSec = "3s";
        StateDirectory = "realm-observability";
        RuntimeDirectory = "realm-observability";
        RuntimeDirectoryMode = "0700";
        Environment = [
          "XDG_DATA_HOME=/var/lib/realm-observability"
          "XDG_CONFIG_HOME=/var/lib/realm-observability"
          "HOME=/var/lib/realm-observability"
        ];
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectProc = "invisible";
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        LockPersonality = true;
        NoNewPrivileges = true;
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        UMask = "0027";
      };
    };
    # Caddy is the native SPIFFE terminator: it reads the Workload API directly,
    # so no ghostunnel sits in front of it. It keeps host networking because it
    # binds the mesh address and must reach loopback exporters.
    realm.workloads.observability = {
      unit = "realm-observability.service";
      runtime = "external";
      inherit spiffeID;
      isolation.privateNetwork = false;
      ingress.metrics = {
        backend.kind = "native";
        port = cfg.port;
        service = "observability-${hostName}";
        allowedIDs = cfg.allowedIDs;
      };
    };
    # Business listeners export their identity and address through the same catalog.
    realm.serviceDiscovery.publish = lib.mapAttrs' (
      name: e:
      lib.nameValuePair e.businessService {
        unit = "realm-observability.service";
        port = e.businessProxyPort;
        serverID = spiffeID;
        allowedIDs = e.businessAllowedIDs;
      }
    ) (lib.filterAttrs (_: e: e.businessProxyPort != null) endpoints);
  };
}
