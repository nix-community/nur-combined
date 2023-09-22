{ config, lib, pkgs, ... }:

let
  bindLan = config.sane.hosts.by-name."servo".lan-ip;
  bindHn = config.sane.hosts.by-name."servo".wg-home.ip;
  bindOvpn = "10.0.1.5";
in
{
  services.trust-dns.enable = true;

  services.trust-dns.settings.listen_addrs_ipv4 = [
    # specify each address explicitly, instead of using "*".
    # this ensures responses are sent from the address at which the request was received.
    # it also allows to respond with different data based on the source of the traffic
    "%LISTEN%"
  ];
  # don't bind to IPv6 until i explicitly test that stack
  services.trust-dns.settings.listen_addrs_ipv6 = [];
  services.trust-dns.quiet = true;
  # services.trust-dns.debug = true;

  sane.ports.ports."53" = {
    protocol = [ "udp" "tcp" ];
    visibleTo.lan = true;
    visibleTo.wan = true;
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
    A."wan" = "%AWAN%";
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

  services.trust-dns.package =
    let
      sed = "${pkgs.gnused}/bin/sed";
      zone-dir = "/var/lib/trust-dns";
      zone-wan = "${zone-dir}/wan/uninsane.org.zone";
      zone-lan = "${zone-dir}/lan/uninsane.org.zone";
      zone-hn = "${zone-dir}/hn/uninsane.org.zone";
      zone-template = pkgs.writeText "uninsane.org.zone.in" config.sane.dns.zones."uninsane.org".rendered;
      hn-resolver-config = pkgs.writeText "hn-resolver-config.toml" ''
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

        listen_addrs_ipv4 = ["${bindHn}"]
        listen_addrs_ipv6 = []

        [[zones]]
        zone = "uninsane.org"
        zone_type = "Forward"
        stores = { type = "forward", name_servers = [{ socket_addr = "${bindHn}:1053", protocol = "udp", trust_nx_responses = true }] }

        [[zones]]
        # forward the root zone to the local DNS resolver
        zone = "."
        zone_type = "Forward"
        stores = { type = "forward", name_servers = [{ socket_addr = "127.0.0.53:53", protocol = "udp", trust_nx_responses = true }] }
      '';

      # TODO: rework this shell script to be independent systemd services per trust-dns instance.
    in pkgs.writeShellScriptBin "trust-dns" ''
      # intercept args meant for the real trust-dns, so i can modify them
      _arg__config="$1" # --config
      shift
      orig_config="$1"  # /path/to/config.toml
      shift

      # compute IP address of self for each interface
      mkdir -p ${zone-dir}/{wan,lan,hn}
      wan=$(cat '${config.sane.services.dyn-dns.ipPath}')
      lan=${bindLan}
      hn=${bindHn}
      lanAndOvpn='${bindLan}", "${bindOvpn}'

      # create specializations that resolve native.uninsane.org to different CNAMEs
      ${sed} \
        -e s/%AWAN%/$wan/ \
        -e s/%CNAMENATIVE%/wan/ \
        -e s/%ANATIVE%/$wan/ \
        ${zone-template} > ${zone-wan}
      # to service WAN, listen both on LAN interface and the OVPN interface
      sed "s/%LISTEN%/$lanAndOvpn/" $orig_config > ${zone-dir}/wan-config.toml

      ${sed} \
        -e s/%AWAN%/$wan/ \
        -e s/%CNAMENATIVE%/servo.lan/ \
        -e s/%ANATIVE%/$lan/ \
        ${zone-template} > ${zone-lan}
      # to service LAN, listen only on the LAN
      sed s/%LISTEN%/$lan/ $orig_config > ${zone-dir}/lan-config.toml

      ${sed} \
        -e s/%AWAN%/$wan/ \
        -e s/%CNAMENATIVE%/servo.hn/ \
        -e s/%ANATIVE%/$hn/ \
       ${zone-template} > ${zone-hn}
      # to service wireguard, listen only on hn
      sed s/%LISTEN%/$hn/ $orig_config > ${zone-dir}/hn-config.toml

      # launch the different interfaces, separately
      ${pkgs.trust-dns}/bin/trust-dns \
        --zonedir "${zone-dir}/wan/" --config "${zone-dir}/wan-config.toml" \
        "$@" &
      WANPID=$!

      ${pkgs.trust-dns}/bin/trust-dns --port 1053 \
        --zonedir "${zone-dir}/lan/" --config "${zone-dir}/lan-config.toml" \
        "$@" &
      LANPID=$!

      ln -sf ${hn-resolver-config} ${zone-dir}/hn-resolver-config.toml
      ${pkgs.trust-dns}/bin/trust-dns \
        --config "${zone-dir}/hn-resolver-config.toml" \
        "$@" &
      HNRESOLVERPID=$!

      ${pkgs.trust-dns}/bin/trust-dns --port 1053 \
        --zonedir "${zone-dir}/hn/" --config "${zone-dir}/hn-config.toml" \
        "$@" &
      HNPID=$!

      # wait until any of the processes exits, then kill them all and exit error
      while kill -0 $WANPID $LANPID $HNRESOLVERPID $HNPID; do
        sleep 5
      done
      kill $WANPID $LANPID $HNRESOLVERPID $HNPID
      exit 1
    '';

  systemd.services.trust-dns.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "trust-dns";
    Group = "trust-dns";
  };
  users.groups.trust-dns = {};
  users.users.trust-dns = {
    group = "trust-dns";
    isSystemUser = true;
  };

  sane.services.dyn-dns.restartOnChange = [ "trust-dns.service" ];

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
