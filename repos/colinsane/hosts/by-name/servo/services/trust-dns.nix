# TODO: split this file apart into smaller files to make it easier to understand
{ config, lib, pkgs, ... }:

let
  nativeAddrs = lib.mapAttrs (_name: builtins.head) config.sane.dns.zones."uninsane.org".inet.A;
  bindOvpn = "10.0.1.5";
in lib.mkMerge [
{
  services.trust-dns.enable = true;

  # don't bind to IPv6 until i explicitly test that stack
  services.trust-dns.settings.listen_addrs_ipv6 = [];
  services.trust-dns.quiet = true;
  # FIXME(2023/11/26): services.trust-dns.debug doesn't log requests: use RUST_LOG=debug env for that.
  # - see: <https://github.com/hickory-dns/hickory-dns/issues/2082>
  # services.trust-dns.debug = true;

  sane.ports.ports."53" = {
    protocol = [ "udp" "tcp" ];
    visibleTo.lan = true;
    visibleTo.wan = true;
    visibleTo.ovpn = true;
    description = "colin-dns-hosting";
  };

  sane.dns.zones."uninsane.org".TTL = 900;

  # SOA record structure: <https://en.wikipedia.org/wiki/SOA_record#Structure>
  # SOA MNAME RNAME (... rest)
  # MNAME = Master name server for this zone. this is where update requests should be sent.
  # RNAME = admin contact (encoded email address)
  # Serial = YYYYMMDDNN, where N is incremented every time this file changes, to trigger secondary NS to re-fetch it.
  # Refresh = how frequently secondary NS should query master
  # Retry = how long secondary NS should wait until re-querying master after a failure (must be < Refresh)
  # Expire = how long secondary NS should continue to reply to queries after master fails (> Refresh + Retry)
  sane.dns.zones."uninsane.org".inet = {
    SOA."@" = ''
      ns1.uninsane.org. admin-dns.uninsane.org. (
                                      2023092101 ; Serial
                                      4h         ; Refresh
                                      30m        ; Retry
                                      7d         ; Expire
                                      5m)        ; Negative response TTL
    '';
    TXT."rev" = "2023092101";

    CNAME."native" = "%CNAMENATIVE%";
    A."@" =      "%ANATIVE%";
    A."servo.wan" = "%AWAN%";
    A."servo.lan" = config.sane.hosts.by-name."servo".lan-ip;
    A."servo.hn" = config.sane.hosts.by-name."servo".wg-home.ip;

    # XXX NS records must also not be CNAME
    # it's best that we keep this identical, or a superset of, what org. lists as our NS.
    # so, org. can specify ns2/ns3 as being to the VPN, with no mention of ns1. we provide ns1 here.
    A."ns1" =    "%ANATIVE%";
    A."ns2" =    "185.157.162.178";
    A."ns3" =    "185.157.162.178";
    A."ovpns" =  "185.157.162.178";
    NS."@" = [
      "ns1.uninsane.org."
      "ns2.uninsane.org."
      "ns3.uninsane.org."
    ];
  };

  services.trust-dns.settings.zones = [ "uninsane.org" ];

  # TODO: can i transform this into some sort of service group?
  # have `systemctl restart trust-dns.service` restart all the individual services?
  systemd.services.trust-dns.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "trust-dns";
    Group = "trust-dns";
    wantedBy = lib.mkForce [];
  };
  systemd.services.trust-dns.enable = false;

  users.groups.trust-dns = {};
  users.users.trust-dns = {
    group = "trust-dns";
    isSystemUser = true;
  };

  # sane.services.dyn-dns.restartOnChange = [ "trust-dns.service" ];

  networking.nat.enable = true;
  networking.nat.extraCommands = ''
    # redirect incoming DNS requests from LAN addresses
    #   to the LAN-specialized DNS service
    # N.B.: use the `nixos-*` chains instead of e.g. PREROUTING
    #   because they get cleanly reset across activations or `systemctl restart firewall`
    #   instead of accumulating cruft
    iptables -t nat -A nixos-nat-pre -p udp --dport 53 \
      -m iprange --src-range 10.78.76.0-10.78.79.255 \
      -j DNAT --to-destination :1053
    iptables -t nat -A nixos-nat-pre -p tcp --dport 53 \
      -m iprange --src-range 10.78.76.0-10.78.79.255 \
      -j DNAT --to-destination :1053
  '';
  sane.ports.ports."1053" = {
    # because the NAT above redirects in nixos-nat-pre, LAN requests behave as though they arrived on the external interface at the redirected port.
    # TODO: try nixos-nat-post instead?
    # TODO: or, don't NAT from port 53 -> port 1053, but rather nat from LAN addr to a loopback addr.
    # - this is complicated in that loopback is a different interface than eth0, so rewriting the destination address would cause the packets to just be dropped by the interface
    protocol = [ "udp" "tcp" ];
    visibleTo.lan = true;
    description = "colin-redirected-dns-for-lan-namespace";
  };
}
{
  systemd.services =
    let
      sed = "${pkgs.gnused}/bin/sed";
      stateDir = "/var/lib/trust-dns";
      zoneTemplate = pkgs.writeText "uninsane.org.zone.in" config.sane.dns.zones."uninsane.org".rendered;

      zoneDirFor = flavor: "${stateDir}/${flavor}";
      zoneFor = flavor: "${zoneDirFor flavor}/uninsane.org.zone";
      mkTrustDnsService = opts: flavor: let
        flags = let baseCfg = config.services.trust-dns; in
          (lib.optional baseCfg.debug "--debug") ++ (lib.optional baseCfg.quiet "--quiet");
        flagsStr = builtins.concatStringsSep " " flags;

        anative = nativeAddrs."servo.${flavor}";

        toml = pkgs.formats.toml { };
        configTemplate = opts.config or (toml.generate "trust-dns-${flavor}.toml" (
          (
            lib.filterAttrsRecursive (_: v: v != null) config.services.trust-dns.settings
          ) // {
            listen_addrs_ipv4 = opts.listen or [ anative ];
          }
        ));
        configFile = "${stateDir}/${flavor}-config.toml";

        port = opts.port or 53;
      in {
        description = "trust-dns Domain Name Server (serving ${flavor})";
        unitConfig.Documentation = "https://trust-dns.org/";

        preStart = ''
          wan=$(cat '${config.sane.services.dyn-dns.ipPath}')
          ${sed} s/%AWAN%/$wan/ ${configTemplate} > ${configFile}
        '' + lib.optionalString (!opts ? config) ''
          mkdir -p ${zoneDirFor flavor}
          ${sed} \
            -e s/%CNAMENATIVE%/servo.${flavor}/ \
            -e s/%ANATIVE%/${anative}/ \
            -e s/%AWAN%/$wan/ \
            -e s/%AOVPNS%/185.157.162.178/ \
            ${zoneTemplate} > ${zoneFor flavor}
        '';
        serviceConfig = config.systemd.services.trust-dns.serviceConfig // {
          ExecStart = ''
            ${pkgs.trust-dns}/bin/${pkgs.trust-dns.meta.mainProgram} \
            --port ${builtins.toString port} \
            --zonedir ${zoneDirFor flavor}/ \
            --config ${configFile} ${flagsStr}
          '';
        };

        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
      };
    in {
      trust-dns-wan = mkTrustDnsService { listen = [ nativeAddrs."servo.lan" bindOvpn ]; } "wan";
      trust-dns-lan = mkTrustDnsService { port = 1053; } "lan";
      trust-dns-hn = mkTrustDnsService { port = 1053; } "hn";
      trust-dns-hn-resolver = mkTrustDnsService {
        config = pkgs.writeText "hn-resolver-config.toml" ''
          # i host a resolver in the wireguard VPN so that clients can resolve DNS through the VPN.
          # (that's what this file achieves).
          #
          # one would expect this resolver could host the authoritative zone for `uninsane.org`, and then forward everything else to the system resolver...
          # and while that works for `dig`, it breaks for `nslookup` (and so `ssh`, etc).
          #
          # DNS responses include a flag for if the responding server is the authority of the zone queried.
          # it seems that default Linux stub resolvers either:
          # - expect DNSSEC when the response includes that bit, or
          # - expect A records to be in the `answer` section instead of `additional` section.
          # or perhaps something more nuanced. but for `nslookup` to be reliable, it has to talk to an
          # instance of trust-dns which is strictly a resolver, with no authority.
          # hence, this config: a resolver which forwards to the actual authority.

          listen_addrs_ipv4 = ["${nativeAddrs."servo.hn"}"]
          listen_addrs_ipv6 = []

          [[zones]]
          zone = "uninsane.org"
          zone_type = "Forward"
          stores = { type = "forward", name_servers = [{ socket_addr = "${nativeAddrs."servo.hn"}:1053", protocol = "udp", trust_nx_responses = true }] }

          [[zones]]
          # forward the root zone to the local DNS resolver
          zone = "."
          zone_type = "Forward"
          stores = { type = "forward", name_servers = [{ socket_addr = "127.0.0.53:53", protocol = "udp", trust_nx_responses = true }] }
        '';
      } "hn-resolver";
    };

  sane.services.dyn-dns.restartOnChange = [
    "trust-dns-wan.service"
    "trust-dns-lan.service"
    "trust-dns-hn.service"
    # "trust-dns-hn-resolver.service"  # doesn't need restart because it doesn't know about WAN IP
  ];
}
]
