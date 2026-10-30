{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.realm.spire.httpAttestation;
  realm = config.realm;
  active = cfg.agent.enable || cfg.server.enable;
  isIPv4 =
    value:
    builtins.match "(0|[1-9][0-9]{0,2})(\\.(0|[1-9][0-9]{0,2})){3}" value != null
    && lib.all (part: builtins.fromJSON part <= 255) (lib.splitString "." value);
  isIPv6 =
    value:
    let
      embedded = if lib.hasInfix "." value then builtins.match "(.*:)([0-9.]+)" value else null;
      normalized = if embedded != null then builtins.elemAt embedded 0 + "0:0" else value;
      halves = lib.splitString "::" normalized;
      groups = part: if part == "" then [ ] else lib.splitString ":" part;
      pieces = lib.concatMap groups halves;
    in
    (embedded == null || isIPv4 (builtins.elemAt embedded 1))
    && lib.all (part: builtins.match "[0-9a-fA-F]{1,4}" part != null) pieces
    && (
      if builtins.length halves == 1 then
        builtins.length pieces == 8
      else
        builtins.length halves == 2 && builtins.length pieces < 8
    );
  literalIP = lib.types.addCheck lib.types.str (value: isIPv4 value || isIPv6 value);
  hostLabel = value: builtins.match "[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?" value != null;
  fqdnType = lib.types.addCheck lib.types.str (
    value:
    builtins.stringLength value <= 253
    && builtins.length (lib.splitString "." value) >= 2
    && lib.all hostLabel (lib.splitString "." value)
  );
  bundleText =
    if cfg.trustBundle.text != null then
      cfg.trustBundle.text
    else if cfg.trustBundle.path != null && builtins.pathExists cfg.trustBundle.path then
      builtins.readFile cfg.trustBundle.path
    else
      "";
  bundle = pkgs.writeText "realm-spire-http-trust-bundle.pem" bundleText;
  pinnedBundle = cfg.trustBundle.text != null || cfg.trustBundle.path != null;
  bundlePath = if pinnedBundle then toString bundle else cfg.agent.trustBundlePath;
  checkRuntimeBundle = pkgs.writeShellScript "realm-spire-check-public-bundle" ''
    if ! ${lib.getExe pkgs.gnugrep} -q -- '-----BEGIN CERTIFICATE-----' ${lib.escapeShellArg bundlePath} \
      || ${lib.getExe pkgs.gnugrep} -q -- 'PRIVATE KEY' ${lib.escapeShellArg bundlePath}; then
      echo 'realm.spire.httpAttestation: the runtime public trust bundle must contain a certificate and no private keys.' >&2
      exit 1
    fi
  '';
  agentConfig = pkgs.writeText "realm-node-attest-agent.json" (
    builtins.toJSON (
      {
        inherit (cfg) fqdn;
        trust_domain = realm.trustDomain;
        control_socket = cfg.controlSocket;
      }
      // lib.optionalAttrs cfg.metrics.enable {
        metrics_address = "127.0.0.1:${toString cfg.metrics.agentPort}";
      }
    )
  );
  serverConfig = pkgs.writeText "realm-node-attest-server.json" (
    builtins.toJSON (
      {
        trust_domain = realm.trustDomain;
        inherit (cfg.server) nodes;
        inherit (cfg) port;
        trust_http_transport = cfg.trustHttpTransport;
      }
      // lib.optionalAttrs cfg.metrics.enable {
        metrics_address = "127.0.0.1:${toString cfg.metrics.serverPort}";
      }
    )
  );
  socketNames = [
    "realm-node-attest-control.socket"
  ]
  ++ lib.optional (cfg.responder.ipv4Address != null) "realm-node-attest-http4.socket"
  ++ lib.optional (cfg.responder.ipv6Address != null) "realm-node-attest-http6.socket";
  httpSocket = name: address: {
    wantedBy = [ "sockets.target" ];
    listenStreams = [ address ];
    socketConfig = {
      Service = "realm-node-attest-responder.service";
      FileDescriptorName = name;
      FreeBind = true;
    }
    // lib.optionalAttrs (name == "http6") { BindIPv6Only = "ipv6-only"; };
  };
in
{
  options.realm.spire.httpAttestation = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ../pkgs/realm-node-attest { };
      defaultText = lib.literalExpression "pkgs.callPackage ../pkgs/realm-node-attest { }";
      description = "Package with the HTTP node attestors and responder.";
    };
    # Deployment must supply a trusted HTTP path to the allowed policy addresses.
    # Ordinary DNS and mesh membership are not cryptographic proof of node identity.
    trustHttpTransport = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Acknowledge that deployment supplies trusted HTTP paths to the explicit allowed node addresses.";
    };
    fqdn = lib.mkOption {
      type = fqdnType;
      default = "${config.networking.hostName}.nyaw.xyz";
      description = "Public FQDN served by this node's responder.";
    };
    controlSocket = lib.mkOption {
      type = lib.types.str;
      default = "/run/realm-node-attest/control.sock";
      description = "Root-only Unix socket for the agent to publish challenges.";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 18091;
      description = "Public TCP port for the independent HTTP responder.";
    };
    metrics = {
      enable = lib.mkEnableOption "HTTP attestation metrics on loopback listeners";
      agentPort = lib.mkOption {
        type = lib.types.port;
        default = 18491;
      };
      serverPort = lib.mkOption {
        type = lib.types.port;
        default = 18492;
      };
      responderPort = lib.mkOption {
        type = lib.types.port;
        default = 18493;
      };
    };
    trustBundle = {
      path = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Existing public PEM trust bundle. Nix copies its contents into the store.";
      };
      text = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
        description = "Pinned public PEM trust bundle. This must contain no private keys.";
      };
    };
    agent = {
      enable = lib.mkEnableOption "HTTP FQDN node attestation" // {
        default = realm.enable;
        defaultText = lib.literalExpression "config.realm.enable";
      };
      trustBundlePath = lib.mkOption {
        type = lib.types.nullOr (lib.types.addCheck lib.types.str (lib.hasPrefix "/"));
        default = if pinnedBundle then null else "/etc/realm-spire/trust-bundle.pem";
        defaultText = lib.literalExpression ''
          if trustBundle.text != null || trustBundle.path != null then null
          else "/etc/realm-spire/trust-bundle.pem"
        '';
        description = ''
          Absolute path to a public PEM bundle at runtime, when no pinned source exists.
          Pinned trustBundle.path or trustBundle.text takes precedence over this path.
          This file must contain no private keys. Nix does not read or copy it.
          The agent skips startup until the file exists and checks its contents before startup.
        '';
      };
    };
    server = {
      enable = lib.mkEnableOption "HTTP FQDN server attestation" // {
        default = realm.spire.server.enable;
        defaultText = lib.literalExpression "config.realm.spire.server.enable";
      };
      nodes = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule (
            { name, ... }:
            {
              options = {
                fqdn = lib.mkOption {
                  type = fqdnType;
                  default = "${name}.nyaw.xyz";
                };
                addresses = lib.mkOption {
                  type = lib.types.listOf literalIP;
                  description = "Explicit allowed literal IPv4 or IPv6 addresses from the node registry, including mesh ULA addresses. No DNS lookup occurs.";
                };
              };
            }
          )
        );
        default = { };
        description = "Explicit HTTP node declarations, keyed by hostname. These also declare stable node aliases.";
      };
    };
    responder = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = cfg.agent.enable;
        defaultText = lib.literalExpression "config.realm.spire.httpAttestation.agent.enable";
        description = "Run the independent responder, even when Realm and SPIRE are disabled.";
      };
      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open the public responder TCP port in the host firewall.";
      };
      ipv4Address = lib.mkOption {
        type = lib.types.nullOr (lib.types.addCheck lib.types.str isIPv4);
        default = "0.0.0.0";
        description = "Host IPv4 bind address. Null disables the IPv4 listener.";
      };
      ipv6Address = lib.mkOption {
        type = lib.types.nullOr (lib.types.addCheck lib.types.str isIPv6);
        default = "::";
        description = "Host IPv6 bind address. Null disables the IPv6 listener.";
      };
    };
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !active || cfg.trustHttpTransport;
          message = "realm.spire.httpAttestation: set trustHttpTransport to acknowledge the trusted HTTP paths supplied by deployment.";
        }
        {
          assertion = !cfg.agent.enable || realm.enable;
          message = "realm.spire.httpAttestation: the HTTP agent requires realm.enable.";
        }
        {
          assertion = !cfg.server.enable || (realm.enable && realm.spire.server.enable);
          message = "realm.spire.httpAttestation: the HTTP server requires the Realm SPIRE server.";
        }
        {
          assertion =
            !(cfg.trustBundle.path != null && cfg.trustBundle.text != null)
            && (!cfg.agent.enable || pinnedBundle || cfg.agent.trustBundlePath != null);
          message = "realm.spire.httpAttestation: set at most one pinned bundle source and supply a pinned or runtime public trust bundle for the HTTP agent.";
        }
        {
          assertion =
            !cfg.agent.enable
            || !pinnedBundle
            || (
              lib.hasInfix "-----BEGIN CERTIFICATE-----" bundleText && !(lib.hasInfix "PRIVATE KEY" bundleText)
            );
          message = "realm.spire.httpAttestation: the pinned public trust bundle must contain a certificate and no private keys.";
        }
        {
          assertion =
            !(active || cfg.responder.enable)
            || (
              lib.hasPrefix "/run/" cfg.controlSocket
              && !(lib.hasInfix "/../" cfg.controlSocket)
              && lib.hasSuffix ".sock" cfg.controlSocket
            );
          message = "realm.spire.httpAttestation: controlSocket must be an absolute socket path below /run/.";
        }
        {
          assertion =
            !cfg.responder.enable || (cfg.responder.ipv4Address != null || cfg.responder.ipv6Address != null);
          message = "realm.spire.httpAttestation: enable at least one responder HTTP listener.";
        }
        {
          assertion = !cfg.server.enable || lib.all hostLabel (builtins.attrNames cfg.server.nodes);
          message = "realm.spire.httpAttestation: server node keys must be hostnames with one DNS label.";
        }
        {
          assertion =
            !cfg.server.enable || lib.all (node: node.addresses != [ ]) (builtins.attrValues cfg.server.nodes);
          message = "realm.spire.httpAttestation: each server node requires explicit allowed IP addresses.";
        }
      ];
    }
    (lib.mkIf (realm.enable && cfg.agent.enable) {
      services.spire.agent.settings = {
        agent = {
          trust_bundle_path = bundlePath;
          rebootstrap_mode = "always";
          # SPIRE defaults to 10m after an expired cache. Keep recovery within
          # the Agent unit's 300s startup gate instead of timing out each retry.
          rebootstrap_delay = lib.mkDefault "30s";
        };
        plugins.NodeAttestor = {
          http_fqdn = {
            plugin_cmd = "${cfg.package}/bin/realm-node-attest-agent";
            plugin_data.config_file = toString agentConfig;
          };
        };
      };
      systemd.services.spire-agent = {
        unitConfig.ConditionPathExists = bundlePath;
        serviceConfig.ExecStartPre = lib.mkIf (!pinnedBundle) [ checkRuntimeBundle ];
        wants = lib.mkIf cfg.responder.enable socketNames;
        after = lib.mkIf cfg.responder.enable socketNames;
      };
    })
    (lib.mkIf (realm.enable && realm.spire.server.enable && cfg.server.enable) {
      services.spire.server.settings.plugins.NodeAttestor.http_fqdn = {
        plugin_cmd = "${cfg.package}/bin/realm-node-attest-server";
        plugin_data.config_file = toString serverConfig;
      };
      # Map the stable node alias to the attested HTTP agent ID.
      # The reconciler owns these entries, including removal after opt-out.
      realm.spire.server.registrations = lib.mapAttrs (
        host: _:
        let
          agentID = "spiffe://${realm.trustDomain}/spire/agent/http_fqdn/${host}";
        in
        {
          http-agent-alias = {
            parentID = agentID;
            spiffeID = "spiffe://${realm.trustDomain}/agent/${host}";
            selectors = [ "spiffe_id:${agentID}" ];
          };
        }
      ) cfg.server.nodes;
    })
    (lib.mkIf cfg.responder.enable {
      networking.firewall.allowedTCPPorts = lib.mkIf cfg.responder.openFirewall [ cfg.port ];
      systemd.sockets = {
        realm-node-attest-http4 = lib.mkIf (cfg.responder.ipv4Address != null) (
          httpSocket "http4" "${cfg.responder.ipv4Address}:${toString cfg.port}"
        );
        realm-node-attest-http6 = lib.mkIf (cfg.responder.ipv6Address != null) (
          httpSocket "http6" "[${cfg.responder.ipv6Address}]:${toString cfg.port}"
        );
        realm-node-attest-control = {
          wantedBy = [ "sockets.target" ];
          listenStreams = [ cfg.controlSocket ];
          socketConfig = {
            Service = "realm-node-attest-responder.service";
            FileDescriptorName = "control";
            SocketUser = "root";
            SocketGroup = "root";
            SocketMode = "0600";
            DirectoryMode = "0755";
            RemoveOnStop = true;
          };
        };
      };
      systemd.services.realm-node-attest-responder = {
        description = "Independent HTTP FQDN attestation responder";
        wantedBy = lib.optional cfg.metrics.enable "multi-user.target";
        requires = lib.optionals cfg.metrics.enable socketNames;
        after = lib.optionals cfg.metrics.enable socketNames;
        serviceConfig = {
          ExecStart = lib.escapeShellArgs (
            [
              "${cfg.package}/bin/realm-node-attest-responder"
              "--fqdn"
              cfg.fqdn
              "--port"
              (toString cfg.port)
              "--control-socket"
              cfg.controlSocket
            ]
            ++ lib.optionals cfg.metrics.enable [
              "--metrics-address"
              "127.0.0.1:${toString cfg.metrics.responderPort}"
            ]
          );
          Sockets = socketNames;
          DynamicUser = true;
          User = "realm-node-attest";
          PrivateNetwork = false;
          Restart = "on-failure";
          NoNewPrivileges = true;
          CapabilityBoundingSet = "";
          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectProc = "invisible";
          ProtectKernelTunables = true;
          ProtectControlGroups = true;
          MemoryMax = "64M";
          TasksMax = 64;
          CPUQuota = "50%";
          PrivateTmp = true;
          PrivateDevices = true;
          RestrictSUIDSGID = true;
          RestrictNamespaces = true;
          RestrictAddressFamilies = [
            "AF_UNIX"
            "AF_INET"
            "AF_INET6"
          ];
          SystemCallArchitectures = "native";
          UMask = "0077";
        };
      };
    })
  ];
}
