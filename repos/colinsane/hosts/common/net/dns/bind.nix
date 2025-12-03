# debugging:
# - /var/log/named/named.log
## config
# - `man named`
# - `man named.conf`
#   - show defaults with: `named -C`
#   - defaults live in <repo:isc-projects/bind:bin/named/config.c>
#   - per-option docs live in <repo:isc-projects/bind:bind9/doc/arm/reference.rst>
#
## statistics
# - `netstat --statistics --udp`
# - `rdnc stats`? dumps to `named.stats` in named's PWD?
#
## interactive debugging
# - `systemctl stop bind`
# - `sudo /nix/store/0zpdy93sd3fgbxgvf8dsxhn8fbbya8d2-bind-9.18.28/sbin/named -g -u named -4 -c /nix/store/f1mp0myzmfms71h9vinwxpn2i9362a9a-named.conf`
#   - `-g` = don't fork
#   - `-u named` = start as superuser (to claim port 53), then drop to user `named`
#
{ config, lib, pkgs, ... }:
let
  hostCfg = config.sane.hosts.by-name."${config.networking.hostName}" or null;
  bindCfg = config.services.bind;
in
lib.optionalAttrs false  #< XXX(2025-09-08): using kresd / knot-resolver now
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
    ] ++ lib.optionals (hostCfg != null && hostCfg.wg-home.ip != null) [
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

    # services.bind.extraArgs = [
    #   # -d = debug logging level: higher = more verbose
    #   "-d" "2"
    #   # -L = where to log. default is `named.run` in PWD -- unless running interactively in which case it logs to stdout
    #   "-L" "/var/log/named/named.log"
    # ];

    networking.resolvconf.useLocalResolver = false;  #< we manage resolvconf explicitly, above

    # TODO: how to exempt `pool.ntp.org` from DNSSEC checks, as i did when using unbound?

    # allow runtime insertion of zones or other config changes:
    # add your supplemental config as a toplevel file in /run/named/dhcp-configs/, then `systemctl restart bind`
    services.bind.extraConfig = ''
      include "/run/named/dhcp-configs.conf";
    '';
    services.bind.extraOptions = ''
      // we can't guarantee that all forwarders support DNSSEC,
      // and as of 2025-01-30 BIND9 gives no way to disable DNSSEC per-forwarder/zone,
      // so just disable it globally
      dnssec-validation no;
      // XXX(2025-06-30): i need reverse DNS of private IP space such as 10.0.0.0/8.
      // configuring those zones (done in a secrets/ file), unfortunately requires disabling
      // ALL local entries for reserved zones (IN-ADDR.ARPA, IP6.ARPA, EMPTY.AS112.ARPA, HOME.ARPA, RESOLVER.ARPA).
      // TODO: figure a better solution, as this likely causes reverse-DNS queries of LAN hosts to be sent to the WAN!
      // - see <https://www.as112.net/>
      empty-zones-enable no;
    '';
    # re-implement the nixos default bind config, but without `options { forwarders { }; };`,
    # as having an empty `forwarders` at the top-level prevents me from forwarding the `.` zone in a separate statement
    # (which i want to do to allow sane-vpn to forward all DNS).
    services.bind.configFile = pkgs.writeText "named.conf" ''
      include "/etc/bind/rndc.key";
      controls {
        inet 127.0.0.1 allow {localhost;} keys {"rndc-key";};
      };

      acl cachenetworks { ${lib.concatMapStrings (entry: " ${entry}; ") bindCfg.cacheNetworks} };
      acl badnetworks { ${lib.concatMapStrings (entry: " ${entry}; ") bindCfg.blockedNetworks} };

      options {
        listen-on { ${lib.concatMapStrings (entry: " ${entry}; ") bindCfg.listenOn} };
        listen-on-v6 { ${lib.concatMapStrings (entry: " ${entry}; ") bindCfg.listenOnIpv6} };
        allow-query-cache { cachenetworks; };
        blackhole { badnetworks; };
        //v disable top-level forwards, so that i can do forwarding more generically in `zone FOO { ... }` directives.
        // forward ${bindCfg.forward};
        // forwarders { ${lib.concatMapStrings (entry: " ${entry}; ") bindCfg.forwarders} };
        directory "${bindCfg.directory}";
        pid-file "/run/named/named.pid";
        ${bindCfg.extraOptions}
      };

      // XXX(2025-06-18): some tools i use for work assume 'localhost' can be resolved by the system nameserver,
      // and not just by /etc/hosts
      zone "localhost" {
        type master;
        file "${pkgs.writeText "localhost" ''
          $TTL 300
          @               IN      SOA     localhost. root.localhost. (
                                          202506181       ; Serial
                                          28800   ; Refresh
                                          7200    ; Retry
                                          604800  ; Expire
                                          86400)  ; Minimum TTL
                                  NS      localhost.

          localhost.              A        127.0.0.1
                                  AAAA     ::1
        ''}";
      };

      ${bindCfg.extraConfig}
    '';

    systemd.services.bind.serviceConfig.ExecStartPre = pkgs.writeShellScript "named-generate-config" ''
      mkdir -p /run/named/dhcp-configs
      chmod g+w /run/named/dhcp-configs
      echo "// FILE GENERATED BY bind.service's ExecStartPre: CHANGES TO THIS FILE WILL BE OVERWRITTEN" > /run/named/dhcp-configs.conf
      for c in $(ls /run/named/dhcp-configs/); do
        cat "/run/named/dhcp-configs/$c" >> /run/named/dhcp-configs.conf
      done
    '';
    systemd.services.bind.serviceConfig.ReadWritePaths = [
      "/var/log/named"
    ];

    sane.persist.sys.byPath."/var/log/named" = {
      store = "ephemeral";
      method = "symlink";
      acl.mode = "0750";
      acl.user = "named";
    };
  };
}
