## config
# - <https://knot-resolver.readthedocs.io/en/stable/config-overview.html>
{ config, lib, ... }:
let
  hostCfg = config.sane.hosts.by-name."${config.networking.hostName}" or null;
in
{
  config = lib.mkIf (!config.sane.services.hickory-dns.asSystemResolver) {
    services.resolved.enable = lib.mkForce false;

    networking.nameservers = [
      # be compatible with systemd-resolved
      # "127.0.0.53"
      # or don't be compatible with systemd-resolved, but with libc and pasta instead
      #   see <pkgs/by-name/sane-scripts/src/sane-vpn>
      "127.0.0.1"
      # enable IPv6, or don't; unbound is spammy when IPv6 is enabled but unroutable
      # "::1"
    ];

    networking.resolvconf.useLocalResolver = false;  #< we manage resolvconf explicitly, above
    networking.resolvconf.extraConfig = ''
      # DNS serviced by `kresd` (knot-resolver) recursive resolver
      name_servers='127.0.0.1'
    '';

    sane.persist.sys.byPath."/var/cache/knot-resolver" = {
      # TODO: store the cache in private store, and restart the service once that's been unlocked?
      store = "plaintext";
      method = "bind";
      acl.mode = "0770";
      acl.user = "knot-resolver";
    };

    services.kresd.enable = true;
    services.kresd.listenPlain = [
      "127.0.0.1:53"
    ] ++ lib.optionals (hostCfg != null && hostCfg.wg-home.ip != null) [
      # allow wireguard clients to use us as a recursive resolver (only needed for servo)
      "${hostCfg.wg-home.ip}:53"
    ];

    # TODO:
    # - [ ] integrate with dhcp-configs
    services.kresd.extraConfig = ''
      -- config docs: <https://www.knot-resolver.cz/documentation/stable/config-overview.html>

      -- we can't guarantee that all forwarders support DNSSEC.
      -- replicating my bind config, and just disabling dnssec universally
      -- dnssec = false
      -- trust_anchors.remove('.')

      net.ipv6 = false
    '';

    systemd.services."kresd@" = {
      # hardening (systemd-analyze security kresd@)
      # upstream .service file sets AmbientCapabilities, CapabilityBoundingSet
      serviceConfig.LockPersonality = true;
      # serviceConfig.MemoryDenyWriteExecute = true;  #< XXX(2025-12-02): required
      serviceConfig.NoNewPrivileges = true;
      serviceConfig.PrivateDevices = true;
      serviceConfig.PrivateMounts = true;
      serviceConfig.PrivateTmp = true;
      # serviceConfig.PrivateUsers = true;  #< XXX(2025-12-02): required
      serviceConfig.ProcSubset = "pid";
      serviceConfig.ProtectClock = true;
      serviceConfig.ProtectControlGroups = true;
      serviceConfig.ProtectHome = true;
      serviceConfig.ProtectHostname = true;
      serviceConfig.ProtectKernelLogs = true;
      serviceConfig.ProtectKernelModules = true;
      serviceConfig.ProtectKernelTunables = true;
      serviceConfig.ProtectProc = "invisible";
      serviceConfig.ProtectSystem = "strict";
      serviceConfig.RemoveIPC = true;
      serviceConfig.RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
      serviceConfig.RestrictNamespaces = true;
      serviceConfig.RestrictSUIDSGID = true;
      serviceConfig.SystemCallArchitectures = "native";
      serviceConfig.SystemCallFilter = [
        "@system-service"
        # "~@privileged"  #< XXX(2025-12-02): required
        # "~@resources"  #< XXX(2025-12-02): required
      ];
    };

    systemd.services.kres-cache-gc = {
      # hardening (systemd-analyze security kresd@)
      # upstream .service file sets AmbientCapabilities, CapabilityBoundingSet
      serviceConfig.LockPersonality = true;
      serviceConfig.MemoryDenyWriteExecute = true;
      serviceConfig.NoNewPrivileges = true;
      serviceConfig.PrivateDevices = true;
      serviceConfig.PrivateNetwork = true;
      serviceConfig.PrivateMounts = true;
      serviceConfig.PrivateTmp = true;
      serviceConfig.PrivateUsers = true;
      serviceConfig.ProcSubset = "pid";
      serviceConfig.ProtectClock = true;
      serviceConfig.ProtectControlGroups = true;
      serviceConfig.ProtectHome = true;
      serviceConfig.ProtectHostname = true;
      serviceConfig.ProtectKernelLogs = true;
      serviceConfig.ProtectKernelModules = true;
      serviceConfig.ProtectKernelTunables = true;
      serviceConfig.ProtectProc = "invisible";
      serviceConfig.ProtectSystem = "full";  #< XXX(2025-12-02): can't be strict
      serviceConfig.RemoveIPC = true;
      serviceConfig.RestrictAddressFamilies = "AF_UNIX";
      serviceConfig.RestrictNamespaces = true;
      serviceConfig.RestrictSUIDSGID = true;
      serviceConfig.SystemCallArchitectures = "native";
      serviceConfig.SystemCallFilter = [
        "@system-service"
        "~@privileged"
        "~@resources"
      ];
    };
  };
}
