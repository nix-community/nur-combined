{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.realm.internet;
  workload = config.realm.workloads.internet;
  ingress = workload.ingress.http;
  settings = import ../lib/realm/envoy-internet.nix {
    inherit lib;
    nodeID = config.networking.hostName;
    address = config.realm.address;
    port = ingress.port;
    spiffeID = workload.spiffeID;
    allowedIDs = ingress.allowedIDs;
    trustDomain = config.realm.trustDomain;
    spireSocket = config.realm.spire.socket;
    inherit (cfg) extraConnectPorts extraConnectPolicies adminPort;
  };
  envoy = pkgs.callPackage ../pkgs/by-name/envoy-realm.nix { };
  configfile = (pkgs.formats.json { }).generate "realm-internet.json" settings;
in
{
  imports = [
    ./realm-workloads.nix
    ./realm-spire.nix
    ./service-discovery.nix
  ];

  options.realm.internet = {
    enable = lib.mkEnableOption "the authenticated Realm Internet proxy";
    port = mkOption {
      type = types.port;
      default = 19328;
      description = "Port for the native mTLS Internet listener.";
    };
    adminPort = mkOption {
      type = types.port;
      default = 19329;
      description = "Port for the loopback Envoy admin interface and Prometheus metrics.";
    };
    allowedIDs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Explicit SPIFFE identities allowed to use the Internet proxy.";
    };
    extraConnectPorts = mkOption {
      type = types.attrsOf (types.listOf types.port);
      default = { };
      description = "Additional CONNECT ports by SPIFFE identity. Each rule is named connect-<identity>.";
    };
    extraConnectPolicies = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            identities = mkOption { type = types.listOf types.str; };
            ports = mkOption { type = types.listOf types.port; };
          };
        }
      );
      default = { };
      description = "Named rules for additional CONNECT ports and explicit SPIFFE identities.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.realm.enable;
        message = "realm.internet: enable realm to run the Internet proxy.";
      }
      {
        assertion = ingress.allowedIDs != [ ];
        message = "realm.internet.allowedIDs: declare at least one allowed caller.";
      }
      {
        assertion =
          !(cfg.extraConnectPolicies ? public-internet)
          && lib.all (id: !(builtins.hasAttr "connect-${id}" cfg.extraConnectPolicies)) (
            builtins.attrNames cfg.extraConnectPorts
          );
        message = "realm.internet: extra CONNECT policy names must not replace public-internet or a generated connect-<identity> rule.";
      }
      {
        assertion =
          lib.all (ports: ports != [ ]) (builtins.attrValues cfg.extraConnectPorts)
          && lib.all (policy: policy.identities != [ ] && policy.ports != [ ]) (
            builtins.attrValues cfg.extraConnectPolicies
          );
        message = "realm.internet: extra CONNECT policies require identities and ports.";
      }
      {
        assertion = lib.all (lib.hasPrefix "spiffe://") (
          ingress.allowedIDs
          ++ builtins.attrNames cfg.extraConnectPorts
          ++ lib.concatMap (policy: policy.identities) (builtins.attrValues cfg.extraConnectPolicies)
        );
        message = "realm.internet: caller identities must be SPIFFE URIs.";
      }
    ];
    environment.etc."realm-internet/config.json".source = configfile;
    realm.observability.endpoints.envoy = {
      port = cfg.adminPort;
      path = "/stats/prometheus";
    };
    # Keep the gateway in its own unit and SPIFFE identity. SPIRE streams
    # the SVID and trust bundle over SDS; private keys stay in memory.
    systemd.services.realm-internet = {
      wantedBy = [ "multi-user.target" ];
      # Static route changes restart the unit. SDS rotates certificates
      # without restarting the gateway.
      restartTriggers = [ configfile ];
      requires = [ "spire-agent.service" ];
      after = lib.mkAfter [
        "network-online.target"
        "spire-agent.service"
      ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "simple";
        User = workload.user;
        Group = workload.group;
        ExecStartPre = "${envoy}/bin/envoy --mode validate --config-path /etc/realm-internet/config.json";
        ExecStart = "${envoy}/bin/envoy --config-path /etc/realm-internet/config.json --concurrency 2 --disable-hot-restart";
        Restart = "on-failure";
        RestartSec = "3s";
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
        CapabilityBoundingSet = [ ];
        AmbientCapabilities = [ ];
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
        ];
        UMask = "0027";
      };
    };

    # The gateway terminates mTLS and uses host networking for public destinations.
    realm.workloads.internet = {
      unit = "realm-internet.service";
      runtime = "external";
      isolation.privateNetwork = false;
      ingress.http = {
        backend.kind = "native";
        port = cfg.port;
        service = "internet-proxy";
        allowedIDs = cfg.allowedIDs;
      };
    };
  };
}
