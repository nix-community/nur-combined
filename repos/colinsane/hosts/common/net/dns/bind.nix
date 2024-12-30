{ config, lib, ... }:
let
  hostCfg = config.sane.hosts.by-name."${config.networking.hostName}";
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

    networking.resolvconf.extraConfig = ''
      # DNS serviced by `BIND` recursive resolver
      name_servers='127.0.0.1'
    '';

    services.bind.enable = lib.mkDefault true;
    services.bind.forwarders = [];  #< don't forward queries to upstream resolvers
    services.bind.cacheNetworks = [
      "127.0.0.0/24"
      "::1/128"
      "10.0.10.0/24"  #< wireguard clients (servo)
    ];
    services.bind.listenOn = [
      "127.0.0.1"
    ] ++ lib.optionals (hostCfg.wg-home.ip != null) [
      # allow wireguard clients to use us as a recursive resolver (only needed for servo)
      hostCfg.wg-home.ip
    ];
    services.bind.listenOnIpv6 = [
      # "::1"
    ];

    services.bind.ipv4Only = true;  # unbound is spammy when it tries IPv6 without a routable address

    # when testing, deploy on a port other than 53
    # services.bind.extraOptions = ''
    #   listen-on port 953 { any; };
    # '';

    networking.resolvconf.useLocalResolver = false;  #< we manage resolvconf explicitly, above

    # TODO: how to exempt `pool.ntp.org` from DNSSEC checks, as i did when using unbound?
  };
}
