# SPIRE control plane and per-node Agent (realm.spire).
#
# HTTP FQDN is the sole node attestor. Deployment supplies the trusted HTTP path
# and public trust bundle. Registrations remain declarative: realm-workloads.nix
# declares workloads, mod/realm.nix collects them, and the reconciler applies them.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.realm;
  scfg = cfg.spire;
  upstream = scfg.server.upstream;
  # Only public PEMs are read during evaluation. The private key stays a runtime
  # string and is handed to systemd without checking or copying its contents.
  publicPEM = path: if path != null && builtins.pathExists path then builtins.readFile path else "";
  certificateCount = text: builtins.length (lib.splitString "-----BEGIN CERTIFICATE-----" text) - 1;
  validPublicPEM =
    text:
    !(lib.hasInfix "PRIVATE KEY" text)
    &&
      builtins.match "[[:space:]]*(-----BEGIN CERTIFICATE-----[[:space:]]+[A-Za-z0-9+/][A-Za-z0-9+/=[:space:]]*-----END CERTIFICATE-----[[:space:]]*)+" text
      != null;
  certificatePEM = publicPEM upstream.certificate;
  bundlePEM = publicPEM upstream.bundle;
  spire = pkgs.spire;
  # Server admin API, used only by the reconciler.
  adminSocket = "/run/spire/server/private/api.sock";
  # The reconciler restarts when this file's store path changes.
  manifest = pkgs.writeText "realm-spire-registrations.json" (
    builtins.toJSON scfg.server.registrations
  );
in
{
  imports = [
    ./realm-spire-http.nix
    ./realm-identity-metrics.nix
  ];

  options.realm.spire = {
    # Workload API socket. It lives in a root:realm-proxies directory, so only
    # proxy accounts and root can request an SVID.
    socket = lib.mkOption {
      type = lib.types.str;
      default = "/run/spire/agent/public/api.sock";
    };
    # Agent to Server address on the mesh; the default assumes eihort.
    serverAddress = lib.mkOption {
      type = lib.types.str;
      default = "eihort.node.mesh.nyaw.xyz";
    };
    # One entry per process that must obtain an SVID, e.g.
    #
    #   realm.spire.registrations.realm-egress-loki-s3 = {
    #     spiffeID = "spiffe://nyaw.xyz/service/loki";
    #     selectors = [
    #       "systemd:id:realm-egress-loki-s3.service"
    #       "unix:user:realm-loki"
    #     ];
    #   };
    #
    # Both selectors must match the running process, so a unit name alone cannot
    # be spoofed by another account on the node.
    registrations = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            spiffeID = lib.mkOption { type = lib.types.str; };
            selectors = lib.mkOption { type = lib.types.listOf lib.types.str; };
          };
        }
      );
      default = { };
      description = "Public registration declarations for the local workload proxies and helpers.";
    };
    server = {
      enable = lib.mkEnableOption "SPIRE control plane on this node";
      upstream = {
        enable = lib.mkEnableOption "disk upstream CA for the SPIRE server";
        certificate = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Public PEM containing exactly one upstream signing CA certificate. Copied to the Nix store; must contain no private key.";
        };
        bundle = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = if upstream.enable then upstream.certificate else null;
          defaultText = lib.literalExpression "if config.realm.spire.server.upstream.enable then config.realm.spire.server.upstream.certificate else null";
          description = "Public PEM trust bundle for the upstream CA, containing one or more certificates and no private keys.";
        };
        keyFile = lib.mkOption {
          type = lib.types.nullOr (lib.types.addCheck lib.types.str (lib.hasPrefix "/"));
          default = null;
          description = ''
            Absolute runtime path to the upstream CA private key. Use a string,
            never a Nix path: Nix must not read or copy the key into the store.
            systemd loads it as the realm-upstream.key service credential.
          '';
        };
      };
      # Declarations from all nodes, keyed by node name and merged by mod/realm.nix.
      registrations = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.attrs);
        default = { };
      };
    };
  };
  config = lib.mkMerge [
    (lib.mkIf upstream.enable {
      assertions = [
        {
          assertion = cfg.enable && scfg.server.enable;
          message = "realm.spire.server.upstream: enabling an upstream CA requires realm.enable and realm.spire.server.enable.";
        }
        {
          assertion = upstream.certificate != null && upstream.bundle != null && upstream.keyFile != null;
          message = "realm.spire.server.upstream: certificate, bundle and keyFile must be configured.";
        }
        {
          assertion = validPublicPEM certificatePEM && certificateCount certificatePEM == 1;
          message = "realm.spire.server.upstream: certificate must contain exactly one complete public PEM certificate and no private keys.";
        }
        {
          assertion = validPublicPEM bundlePEM && certificateCount bundlePEM >= 1;
          message = "realm.spire.server.upstream: bundle must contain one or more complete public PEM certificates and no private keys.";
        }
        {
          assertion = config.services.spire.server.expandEnv;
          message = "realm.spire.server.upstream: services.spire.server.expandEnv must be true for the systemd credential path.";
        }
      ];
      services.spire.server = {
        expandEnv = lib.mkDefault true;
        settings.plugins.UpstreamAuthority.disk.plugin_data = {
          cert_file_path = toString upstream.certificate;
          bundle_file_path = toString upstream.bundle;
          key_file_path = "$CREDENTIALS_DIRECTORY/realm-upstream.key";
        };
      };
      systemd.services.spire-server = {
        serviceConfig.LoadCredential = lib.optional (
          upstream.keyFile != null
        ) "realm-upstream.key:${upstream.keyFile}";
        restartTriggers = lib.filter (path: path != null) [
          upstream.certificate
          upstream.bundle
        ];
      };
    })
    (lib.mkIf cfg.enable (
      lib.mkMerge [
        {
          services.spire.agent = {
            enable = true;
            settings = {
              agent = {
                trust_domain = cfg.trustDomain;
                server_address = scfg.serverAddress;
                socket_path = scfg.socket;
              };
              plugins = {
                # Disk keys preserve the node identity across restarts and upgrades.
                KeyManager.disk.plugin_data.directory = "$STATE_DIRECTORY/keys";
                # systemd attests the unit that requested the SVID, unix attests
                # the account that opened the socket. Proxy paths need both.
                WorkloadAttestor.systemd.plugin_data = { };
                WorkloadAttestor.unix.plugin_data = { };
              };
            };
          };
          systemd.services.spire-agent = {
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            serviceConfig = {
              # root creates the socket in a 0750 directory owned by
              # root:realm-proxies. UMask 0007 keeps the socket away from everyone
              # outside that group while still letting the Agent write it.
              User = lib.mkForce "root";
              Group = lib.mkForce "realm-proxies";
              UMask = lib.mkForce "0007";
              RuntimeDirectoryMode = "0750";
              RestartSec = "5s";
              TimeoutStartSec = "300s";
              # Dependent units get a working API socket instead of racing startup.
              ExecStartPost = lib.escapeShellArgs [
                (lib.getExe' cfg.helperPackage "realm-helper")
                "wait-spire-agent"
                "--spire-agent"
                (lib.getExe' spire "spire-agent")
                "--socket"
                scfg.socket
              ];
            };
          };
        }
        (lib.mkIf scfg.server.enable {
          services.spire.server = {
            enable = true;
            settings = {
              server = {
                trust_domain = cfg.trustDomain;
                # Bind the mesh address only; the Agent talks to it over the mesh.
                bind_address = cfg.address;
                # Short-lived SVIDs limit the value of a leaked key. Connections
                # are separately capped by the one-hour max-conn-lifetime.
                ca_ttl = lib.mkDefault "24h";
                default_x509_svid_ttl = "1h";
              };
              plugins = {
                KeyManager.disk.plugin_data.keys_path = "$STATE_DIRECTORY/keys.json";
                DataStore.sql.plugin_data = {
                  database_type = "sqlite3";
                  connection_string = "$STATE_DIRECTORY/datastore.sqlite3";
                };
              };
            };
          };
          systemd.services.spire-server = {
            wants = [ "network-online.target" ];
            after = [ "network-online.target" ];
            serviceConfig.RestartSec = "5s";
          };
          # Applies the declarative registration set. Entry IDs are derived from
          # the manifest key, so re-running updates instead of duplicating, and
          # only entries this service created before are ever deleted.
          systemd.services.realm-spire-register = {
            description = "Reconcile declarative SPIRE workload registrations";
            wantedBy = [ "multi-user.target" ];
            requires = [ "spire-server.service" ];
            after = [ "spire-server.service" ];
            restartTriggers = [ manifest ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              StateDirectory = "realm-spire-registrations";
              StateDirectoryMode = "0700";
              # The reconciler only runs the server CLI over the admin socket and
              # writes its own state directory. Nothing else is mounted, reachable
              # or needed.
              #
              # The SPIRE server owns its socket directory as a dynamic user with
              # mode 0700, and a capability-less UID 0 cannot enter it; DAC override
              # is the one privilege this unit needs.
              NoNewPrivileges = true;
              CapabilityBoundingSet = [ "CAP_DAC_OVERRIDE" ];
              AmbientCapabilities = [ "CAP_DAC_OVERRIDE" ];
              ProtectSystem = "strict";
              ProtectHome = true;
              PrivateTmp = true;
              PrivateDevices = true;
              RestrictSUIDSGID = true;
              RestrictNamespaces = true;
              RestrictAddressFamilies = [ "AF_UNIX" ];
              SystemCallArchitectures = "native";
              UMask = "0077";
              ExecStart = lib.escapeShellArgs [
                "${config.realm.helperPackage}/bin/realm-helper"
                "spire-register"
                "--spire-server"
                "${spire}/bin/spire-server"
                "--socket"
                adminSocket
                "--manifest"
                manifest
                "--state"
                "/var/lib/realm-spire-registrations/entries.json"
              ];
            };
          };
        })
      ]
    ))
  ];
}
