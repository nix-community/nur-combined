# SPIRE control plane and per-node Agent (realm.spire).
#
# eihort runs the Server; every mesh node runs one Agent. The trust domain is
# independent of the discovery DNS domain: SVIDs say spiffe://nyaw.xyz/... while
# discovery answers come from mesh.nyaw.xyz.
#
# Enrollment is a bootstrapping step, not a workload capability. A node receives
# a single-use join token and the public trust bundle over the existing root SSH
# trust boundary:
#
#   ssh root@eihort realm-enroll eihort | ssh root@eihort realm-install-enrollment
#   ssh root@eihort realm-enroll abhoth | ssh root@abhoth realm-install-enrollment
#
# After enrollment, registrations are declared in Nix. realm-workloads.nix adds
# one entry per proxy/helper unit on its own node; mod/realm.nix collects them
# from every enabled configuration, attaches the node's Agent as parent and
# hands the result to the Server, where `realm-helper spire-register` applies it.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.realm;
  scfg = cfg.spire;
  spire = pkgs.spire;
  # Server admin API, used by the enrollment command and the reconciler only.
  adminSocket = "/run/spire/server/private/api.sock";
  # The reconciler restarts when this file's store path changes.
  manifest = pkgs.writeText "realm-spire-registrations.json" (
    builtins.toJSON scfg.server.registrations
  );
  # Administrative half of enrollment: issue a short-lived, single-use join token
  # together with the public bundle. The caller pipes the JSON straight into the
  # target node, so the token is never written to a log or to the Nix store.
  #
  # The command itself lives in realm-helper; these wrappers only fill in the
  # paths and hostnames that must come from the configuration.
  enroll = pkgs.writeShellScriptBin "realm-enroll" ''
    exec ${lib.getExe' cfg.helperPackage "realm-helper"} enroll \
      --spire-server ${lib.getExe' spire "spire-server"} \
      --socket ${lib.escapeShellArg adminSocket} \
      --manifest ${manifest} \
      --trust-domain ${lib.escapeShellArg cfg.trustDomain} \
      "$@"
  '';
  # Target half of enrollment. The hostname is compiled in, so a command sent to
  # the wrong machine fails instead of enrolling it.
  installEnrollment = pkgs.writeShellScriptBin "realm-install-enrollment" ''
    exec ${lib.getExe' cfg.helperPackage "realm-helper"} install-enrollment \
      --node ${lib.escapeShellArg config.networking.hostName} \
      --systemctl ${lib.getExe' config.systemd.package "systemctl"} \
      "$@"
  '';
in
{
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
      # Declarations from all nodes, keyed by node name and merged by mod/realm.nix.
      registrations = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.attrs);
        default = { };
      };
    };
  };
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.spire.agent = {
          enable = true;
          settings = {
            agent = {
              trust_domain = cfg.trustDomain;
              server_address = scfg.serverAddress;
              socket_path = scfg.socket;
              # Written by realm-install-enrollment. The unit is skipped until the
              # bundle exists, so an unenrolled node does not restart-loop.
              join_token_file = "/var/lib/realm-spire/join-token";
              trust_bundle_path = "/var/lib/realm-spire/trust-bundle.pem";
            };
            plugins = {
              # Keys live in the state directory, so a restart or upgrade keeps
              # the node identity instead of needing a new join token.
              KeyManager.disk.plugin_data.directory = "$STATE_DIRECTORY/keys";
              NodeAttestor.join_token.plugin_data = { };
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
          unitConfig.ConditionPathExists = "/var/lib/realm-spire/trust-bundle.pem";
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
        environment.systemPackages = [ installEnrollment ];
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
              default_x509_svid_ttl = "1h";
            };
            plugins = {
              KeyManager.disk.plugin_data.keys_path = "$STATE_DIRECTORY/keys.json";
              DataStore.sql.plugin_data = {
                database_type = "sqlite3";
                connection_string = "$STATE_DIRECTORY/datastore.sqlite3";
              };
              NodeAttestor.join_token.plugin_data = { };
            };
          };
        };
        systemd.services.spire-server = {
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
          serviceConfig.RestartSec = "5s";
        };
        environment.systemPackages = [ enroll ];
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
  );
}
