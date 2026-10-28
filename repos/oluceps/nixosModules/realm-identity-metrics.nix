{
  config,
  lib,
  pkgs,
  options,
  ...
}:
let
  cfg = config.realm.spire.metrics;
  realm = config.realm;
  enabled = realm.enable && cfg.enable;
  observationEndpoints = lib.hasAttrByPath [ "realm" "observability" "endpoints" ] options;
  server = realm.spire.server.enable;
  address = port: "127.0.0.1:${toString port}";
  canaryID = "spiffe://${realm.trustDomain}/observer/identity/${config.networking.hostName}";
  proxyUnits = lib.filter (
    name: lib.hasPrefix "realm-egress-" name || lib.hasPrefix "realm-ingress-" name
  ) (builtins.attrNames realm.spire.registrations);
  # Status ports must not move when a registration is added or removed. An
  # index-derived port makes a new egress shift every later unit, so during
  # activation the new process binds a port an older process still holds.
  # Derive each port from the stable registration name instead.
  statusPortRange = 10000;
  statusPort =
    unit:
    let
      digest = builtins.substring 0 7 (builtins.hashString "sha256" unit);
      value = (builtins.fromTOML "n = 0x${digest}").n;
    in
    cfg.statusPortBase + lib.mod value statusPortRange;
  statusPorts = lib.listToAttrs (map (unit: lib.nameValuePair unit (statusPort unit)) proxyUnits);
  workloadSources =
    map (unit: {
      unit = "${unit}.service";
      identity = realm.spire.registrations.${unit}.spiffeID;
      address = address cfg.statusPorts.${unit};
      source = "ghostunnel_status_watch";
    }) proxyUnits
    ++ lib.optional (realm.observability.enable or false) {
      unit = "realm-observability.service";
      identity = "${realm.servicePrefix}observability-${config.networking.hostName}";
      address = address cfg.caddyPort;
      source = "caddy_loaded";
    }
    ++ lib.optional (realm.internet.enable or false) {
      unit = "realm-internet.service";
      identity = realm.workloads.internet.spiffeID;
      address = address realm.internet.adminPort;
      source = "envoy_loaded";
    };
  serverHost =
    if lib.hasInfix ":" realm.spire.serverAddress then
      "[${realm.spire.serverAddress}]"
    else
      realm.spire.serverAddress;
  exporterConfig = pkgs.writeText "realm-identity-metrics.json" (
    builtins.toJSON (
      {
        node = config.networking.hostName;
        trust_domain = realm.trustDomain;
        listen_address = address cfg.exporterPort;
        bundle_path = config.services.spire.agent.settings.agent.trust_bundle_path;
        server_address = "${serverHost}:${
          toString (config.services.spire.agent.settings.agent.server_port or 8081)
        }";
        workload_socket = realm.spire.socket;
        systemctl_binary = "${pkgs.systemd}/bin/systemctl";
        workloads = workloadSources;
      }
      // lib.optionalAttrs server {
        server_admin_socket = "/run/spire/server/private/api.sock";
        spire_server_binary = "${pkgs.spire}/bin/spire-server";
        nodes = cfg.nodes;
      }
    )
  );
  nativeTelemetry = port: {
    Prometheus = {
      host = "127.0.0.1";
      inherit port;
    };
    EnableHostnameLabel = false;
  };
in
{
  options.realm.spire.metrics = {
    enable = lib.mkEnableOption "direct SPIRE identity and certificate metrics";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/realm-identity-metrics { };
      description = "Public certificate metadata exporter.";
    };
    exporterPort = lib.mkOption {
      type = lib.types.port;
      default = 18494;
    };
    agentPort = lib.mkOption {
      type = lib.types.port;
      default = 18495;
    };
    serverPort = lib.mkOption {
      type = lib.types.port;
      default = 18496;
    };
    caddyPort = lib.mkOption {
      type = lib.types.port;
      default = 18499;
    };
    statusPortBase = lib.mkOption {
      type = lib.types.port;
      # Keep clear of the old contiguous 28xxx allocation so the first rollout
      # of stable ports cannot collide with proxies that still run old argv.
      default = 30000;
    };
    statusPorts = lib.mkOption {
      type = lib.types.attrsOf lib.types.port;
      readOnly = true;
      default = statusPorts;
      description = "Loopback status ports for each declared SVID proxy.";
    };
    nodes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Expected HTTP agents for the server metadata check.";
    };
    independent = {
      enable = lib.mkEnableOption "WireGuard access to public identity metrics";
      address = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      observers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 18497;
      };
    };
  };
  config = lib.mkIf enabled (
    lib.mkMerge [
      (lib.optionalAttrs observationEndpoints {
        realm.observability.endpoints = {
          spire-agent.port = cfg.agentPort;
          identity.port = cfg.exporterPort;
          attestation-agent.port = realm.spire.httpAttestation.metrics.agentPort;
          attestation-responder.port = realm.spire.httpAttestation.metrics.responderPort;
        }
        // lib.optionalAttrs server {
          spire-server.port = cfg.serverPort;
          attestation-server.port = realm.spire.httpAttestation.metrics.serverPort;
        };
      })
      {
        assertions = [
          {
            assertion = !server || cfg.nodes != [ ];
            message = "realm.spire.metrics: server metadata requires an explicit node list.";
          }
          {
            assertion = realm.observability.enable or false;
            message = "realm.spire.metrics: enable the observation gateway.";
          }
          {
            assertion =
              builtins.length (
                lib.unique (
                  [
                    cfg.exporterPort
                    cfg.agentPort
                    cfg.serverPort
                    cfg.caddyPort
                  ]
                  ++ builtins.attrValues cfg.statusPorts
                )
              ) == 4 + builtins.length proxyUnits;
            message = "realm.spire.metrics: use distinct metrics and status ports.";
          }
          {
            assertion = cfg.statusPortBase + statusPortRange <= 65536;
            message = "realm.spire.metrics: the status port range exceeds TCP ports.";
          }
          {
            assertion =
              builtins.length (lib.unique (builtins.attrValues statusPorts)) == builtins.length proxyUnits;
            message = "realm.spire.metrics: status port hash collision; change statusPortBase.";
          }
        ];
        services.spire.agent.settings = {
          telemetry = nativeTelemetry cfg.agentPort;
          agent.log_format = "json";
        };
        realm.spire.httpAttestation.metrics.enable = true;
        realm.spire.registrations.realm-identity-metrics = {
          spiffeID = canaryID;
          selectors = [
            "systemd:id:realm-identity-metrics.service"
            "unix:user:root"
          ];
        };
        networking.firewall.extraInputRules = lib.optionalString (cfg.statusPorts != { }) ''
          iifname != "lo" tcp dport { ${
            lib.concatMapStringsSep ", " toString ([ cfg.caddyPort ] ++ builtins.attrValues cfg.statusPorts)
          } } drop
        '';
        systemd.services.realm-identity-metrics = {
          description = "SPIRE public certificate and bootstrap trust metrics";
          wantedBy = [ "multi-user.target" ];
          wants = [ "network.target" ];
          after = [ "network.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${lib.getExe cfg.package} --config ${exporterConfig}";
            User = "root";
            Group = "realm-proxies";
            Restart = "on-failure";
            RestartSec = "5s";
            NoNewPrivileges = true;
            CapabilityBoundingSet = lib.optionals server [ "CAP_DAC_OVERRIDE" ];
            AmbientCapabilities = lib.optionals server [ "CAP_DAC_OVERRIDE" ];
            ProtectSystem = "strict";
            ProtectHome = true;
            PrivateTmp = true;
            PrivateDevices = true;
            ProtectProc = "invisible";
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectControlGroups = true;
            ProtectClock = true;
            RestrictSUIDSGID = true;
            RestrictNamespaces = true;
            RestrictAddressFamilies = [
              "AF_UNIX"
              "AF_INET"
              "AF_INET6"
            ];
            InaccessiblePaths = [
              "-/var/lib/spire/agent"
              "-/var/lib/spire/server"
              "-/var/lib/private/spire"
              "-/persist/keys"
            ];
            MemoryMax = "96M";
            TasksMax = 64;
            CPUQuota = "30%";
            UMask = "0077";
          };
        };
      }
      (lib.mkIf server {
        services.spire.server.settings = {
          telemetry = nativeTelemetry cfg.serverPort;
          server.log_format = "json";
        };
      })
      (lib.mkIf cfg.independent.enable {
        assertions = [
          {
            assertion = cfg.independent.address != "" && cfg.independent.observers != [ ];
            message = "realm.spire.metrics: independent access needs a WireGuard address and observer addresses.";
          }
        ];
        networking.firewall.extraInputRules = lib.concatMapStringsSep "\n" (observer: ''
          iifname "hts-0" ip saddr ${observer} ip daddr ${cfg.independent.address} tcp dport ${toString cfg.independent.port} accept
        '') cfg.independent.observers;
        systemd.sockets.realm-identity-heartbeat = {
          wantedBy = [ "sockets.target" ];
          listenStreams = [ "${cfg.independent.address}:${toString cfg.independent.port}" ];
          socketConfig = {
            FreeBind = true;
            IPAddressDeny = "any";
            IPAddressAllow = cfg.independent.observers;
          };
        };
        systemd.services.realm-identity-heartbeat = {
          description = "WireGuard relay for public identity metrics";
          requires = [ "realm-identity-heartbeat.socket" ];
          after = [ "realm-identity-heartbeat.socket" ];
          serviceConfig = {
            ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd ${address cfg.exporterPort}";
            DynamicUser = true;
            NoNewPrivileges = true;
            CapabilityBoundingSet = "";
            PrivateTmp = true;
            PrivateDevices = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            RestrictAddressFamilies = [ "AF_INET" ];
            IPAddressDeny = "any";
            IPAddressAllow = [ "127.0.0.1/32" ] ++ cfg.independent.observers;
            MemoryMax = "24M";
            TasksMax = 32;
          };
        };
      })
    ]
  );
}
