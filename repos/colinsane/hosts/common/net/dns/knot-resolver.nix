## config
# - <https://www.knot-resolver.cz/documentation/latest/config-overview.html>
#
## debugging / runtime management
# - <https://www.knot-resolver.cz/documentation/latest/upgrading-to-6.html#useful-commands-rosetta>
# - `systemctl {start,stop,restart} knot-resolver.service`
#
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
      # DNS serviced by `knot-resolver` recursive resolver
      name_servers='127.0.0.1'
    '';

    sane.persist.sys.byPath."/var/cache/knot-resolver" = {
      # TODO: store the cache in private store, and restart the service once that's been unlocked?
      store = "plaintext";
      method = "bind";
      acl.mode = "0770";
      acl.user = "knot-resolver";
    };

    services.knot-resolver.enable = true;
    services.knot-resolver.settings = {
      # do-ipv6: whether to use IPv6 when contacting upstream servers
      network.do-ipv6 = false;
      network.listen = [
        {
          interface = [ "127.0.0.1" ];
          kind = "dns";
          # freebind = true => allow binding to a non-yet-available address
          freebind = false;
        }
      ] ++ lib.optionals (hostCfg != null && hostCfg.wg-home.ip != null) [
        {
          # allow wireguard clients to use us as a recursive resolver (only needed for servo)
          interface = hostCfg.wg-home.ip;
          kind = "dns";
          freebind = false;
        }
      ];

      dnssec.negative-trust-anchors = [
        # don't require DNSSEC in the ntp path, as DNSSEC requires a time-synchronized clock.
        # ntp.org. in particular would seem to be frequently serving very fresh signatures,
        # which appear to come from the future if the system RTC has inadvertently been
        # switched to local time (i.e. 7-8 hours in the past).
        "ntp.org."
        # "pool.ntp.org."
        # TODO: excluding `ntpns.org.` might not be required.
        # it might be we just exclude the specific ntp server (i.e. `*.nixos.pool.ntp.org`)
        "ntpns.org."  # `NS pool.ntp.org. {a,b,c...}.ntpns.org.`
      ];
    };

    systemd.services.knot-resolver = {
      # hardening (systemd-analyze security knot-resolver)
      # upstream .service file sets AmbientCapabilities, CapabilityBoundingSet
      serviceConfig.LockPersonality = true;
      # serviceConfig.MemoryDenyWriteExecute = true;  #< XXX(2025-12-27): required
      serviceConfig.NoNewPrivileges = true;
      serviceConfig.PrivateDevices = true;
      serviceConfig.PrivateMounts = true;
      serviceConfig.PrivateTmp = true;
      # serviceConfig.PrivateUsers = true;  #< XXX(2025-12-27): required
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
        # "~@privileged"  #< XXX(2025-12-27): required
        "~@resources"
      ];
    };
  };
}
