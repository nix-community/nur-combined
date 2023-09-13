{ config, lib, pkgs, ... }:

{
  services.trust-dns.enable = true;

  services.trust-dns.settings.listen_addrs_ipv4 = [
    # specify each address explicitly, instead of using "*".
    # this ensures responses are sent from the address at which the request was received.
    config.sane.hosts.by-name."servo".lan-ip
    "10.0.1.5"
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
                                      2022122101 ; Serial
                                      4h         ; Refresh
                                      30m        ; Retry
                                      7d         ; Expire
                                      5m)        ; Negative response TTL
    '';
    TXT."rev" = "2023052901";

    CNAME."native" = "%CNAMENATIVE%";
    A."@" =      "%ANATIVE%";
    A."wan" = "%AWAN%";
    A."servo.lan" = config.sane.hosts.by-name."servo".lan-ip;

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
      zone-template = pkgs.writeText "uninsane.org.zone.in" config.sane.dns.zones."uninsane.org".rendered;
    in pkgs.writeShellScriptBin "trust-dns" ''
      # compute wan/lan values
      mkdir -p ${zone-dir}/{ovpn,wan,lan}
      wan=$(cat '${config.sane.services.dyn-dns.ipPath}')
      lan=${config.sane.hosts.by-name."servo".lan-ip}

      # create specializations that resolve native.uninsane.org to different CNAMEs
      ${sed} s/%AWAN%/$wan/ ${zone-template} \
        | ${sed} s/%CNAMENATIVE%/wan/ \
        | ${sed} s/%ANATIVE%/$wan/ \
        > ${zone-wan}
      ${sed} s/%AWAN%/$wan/ ${zone-template} \
        | ${sed} s/%CNAMENATIVE%/servo.lan/ \
        | ${sed} s/%ANATIVE%/$lan/ \
        > ${zone-lan}

      # launch the different interfaces, separately
      ${pkgs.trust-dns}/bin/trust-dns --port 53 --zonedir ${zone-dir}/wan/ $@ &
      WANPID=$!
      ${pkgs.trust-dns}/bin/trust-dns --port 1053 --zonedir ${zone-dir}/lan/ $@ &
      LANPID=$!

      # wait until any of the processes exits, then kill them all and exit error
      while kill -0 $WANPID $LANPID ; do
        sleep 5
      done
      kill $WANPID $LANPID
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
    protocol = [ "udp" "tcp" ];
    visibleTo.lan = true;
    description = "colin-redirected-dns-for-lan-namespace";
  };
}
