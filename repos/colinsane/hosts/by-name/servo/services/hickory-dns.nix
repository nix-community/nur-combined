# TODO: split this file apart into smaller files to make it easier to understand
{ config, lib, ... }:

let
  dyn-dns = config.sane.services.dyn-dns;
  nativeAddrs = lib.mapAttrs (_name: builtins.head) config.sane.dns.zones."uninsane.org".inet.A;
in
{
  sane.ports.ports."53" = {
    protocol = [ "udp" "tcp" ];
    visibleTo.lan = true;
    # visibleTo.wan = true;
    visibleTo.ovpns = true;
    visibleTo.doof = true;
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
    A."servo.doof" = "%ADOOF%";
    A."servo.lan" = config.sane.hosts.by-name."servo".lan-ip;
    A."servo.hn" = config.sane.hosts.by-name."servo".wg-home.ip;

    # XXX NS records must also not be CNAME
    # it's best that we keep this identical, or a superset of, what org. lists as our NS.
    # so, org. can specify ns2/ns3 as being to the VPN, with no mention of ns1. we provide ns1 here.
    A."ns1" =    "%ANATIVE%";
    A."ns2" =    "%ADOOF%";
    A."ovpns" =  "%AOVPNS%";
    NS."@" = [
      "ns1.uninsane.org."
      "ns2.uninsane.org."
    ];
  };

  services.hickory-dns.settings.zones = builtins.attrNames config.sane.dns.zones;

  networking.nat.enable = true;  #< TODO: try removing this?
  # networking.nat.extraCommands = ''
  #   # redirect incoming DNS requests from LAN addresses
  #   #   to the LAN-specialized DNS service
  #   # N.B.: use the `nixos-*` chains instead of e.g. PREROUTING
  #   #   because they get cleanly reset across activations or `systemctl restart firewall`
  #   #   instead of accumulating cruft
  #   iptables -t nat -A nixos-nat-pre -p udp --dport 53 \
  #     -m iprange --src-range 10.78.76.0-10.78.79.255 \
  #     -j DNAT --to-destination :1053
  #   iptables -t nat -A nixos-nat-pre -p tcp --dport 53 \
  #     -m iprange --src-range 10.78.76.0-10.78.79.255 \
  #     -j DNAT --to-destination :1053
  # '';
  # sane.ports.ports."1053" = {
  #   # because the NAT above redirects in nixos-nat-pre, LAN requests behave as though they arrived on the external interface at the redirected port.
  #   # TODO: try nixos-nat-post instead?
  #   # TODO: or, don't NAT from port 53 -> port 1053, but rather nat from LAN addr to a loopback addr.
  #   # - this is complicated in that loopback is a different interface than eth0, so rewriting the destination address would cause the packets to just be dropped by the interface
  #   protocol = [ "udp" "tcp" ];
  #   visibleTo.lan = true;
  #   description = "colin-redirected-dns-for-lan-namespace";
  # };


  sane.services.hickory-dns.enable = true;
  sane.services.hickory-dns.instances = let
    mkSubstitutions = flavor: {
      "%ADOOF%" = config.sane.netns.doof.wg.address.ipv4;
      "%ANATIVE%" = nativeAddrs."servo.${flavor}";
      "%AOVPNS%" = config.sane.netns.ovpns.wg.address.ipv4;
      "%AWAN%" = "$(cat '${dyn-dns.ipPath}')";
      "%CNAMENATIVE%" = "servo.${flavor}";
    };
  in
  {
    doof = {
      substitutions = mkSubstitutions "doof";
      listenAddrsIpv4 = [
        config.sane.netns.doof.veth.initns.ipv4
        config.sane.netns.doof.wg.address.ipv4
        nativeAddrs."servo.lan"
        # config.sane.netns.ovpns.veth.initns.ipv4
      ];
    };
    # hn = {
    #   substitutions = mkSubstitutions "hn";
    #   listenAddrsIpv4 = [ nativeAddrs."servo.hn" ];
    #   enableRecursiveResolver = true;  #< allow wireguard clients to use this as their DNS resolver
    #   # extraConfig = {
    #   #   zones = [
    #   #     {
    #   #       # forward the root zone to the local DNS resolver
    #   #       # to allow wireguard clients to use this as their DNS resolver
    #   #       zone = ".";
    #   #       zone_type = "Forward";
    #   #       stores = {
    #   #         type = "forward";
    #   #         name_servers = [
    #   #           {
    #   #             socket_addr = "127.0.0.53:53";
    #   #             protocol = "udp";
    #   #             trust_nx_responses = true;
    #   #           }
    #   #         ];
    #   #       };
    #   #     }
    #   #   ];
    #   # };
    # };
    # lan = {
    #   substitutions = mkSubstitutions "lan";
    #   listenAddrsIpv4 = [ nativeAddrs."servo.lan" ];
    #   # port = 1053;
    # };
    # wan = {
    #   substitutions = mkSubstitutions "wan";
    #   listenAddrsIpv4 = [
    #     nativeAddrs."servo.lan"
    #   ];
    # };
  };

  systemd.services.hickory-dns-doof.after = [
    # service will fail to bind the veth, otherwise
    "netns-doof-veth.service"
  ];

  sane.services.dyn-dns.restartOnChange = lib.map (c: "${c.service}.service") (builtins.attrValues config.sane.services.hickory-dns.instances);
}
