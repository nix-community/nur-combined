{ config, pkgs, ... }:

{
  sane.services.trust-dns.enable = true;

  sane.services.trust-dns.listenAddrsIPv4 = [
    # specify each address explicitly, instead of using "*".
    # this ensures responses are sent from the address at which the request was received.
    config.sane.hosts.by-name."servo".lan-ip
    "10.0.1.5"
  ];
  sane.services.trust-dns.quiet = true;

  sane.services.trust-dns.zones."uninsane.org".TTL = 900;

  # SOA record structure: <https://en.wikipedia.org/wiki/SOA_record#Structure>
  # SOA MNAME RNAME (... rest)
  # MNAME = Master name server for this zone. this is where update requests should be sent.
  # RNAME = admin contact (encoded email address)
  # Serial = YYYYMMDDNN, where N is incremented every time this file changes, to trigger secondary NS to re-fetch it.
  # Refresh = how frequently secondary NS should query master
  # Retry = how long secondary NS should wait until re-querying master after a failure (must be < Refresh)
  # Expire = how long secondary NS should continue to reply to queries after master fails (> Refresh + Retry)
  sane.services.trust-dns.zones."uninsane.org".inet = {
    SOA."@" = ''
      ns1.uninsane.org. admin-dns.uninsane.org. (
                                      2022122101 ; Serial
                                      4h         ; Refresh
                                      30m        ; Retry
                                      7d         ; Expire
                                      5m)        ; Negative response TTL
    '';
    TXT."rev" = "2022122101";

    # XXX NS records must also not be CNAME
    # it's best that we keep this identical, or a superset of, what org. lists as our NS.
    # so, org. can specify ns2/ns3 as being to the VPN, with no mention of ns1. we provide ns1 here.
    A."ns1" =    "%NATIVE%";
    A."ns2" =    "185.157.162.178";
    A."ns3" =    "185.157.162.178";
    A."ovpns" =  "185.157.162.178";
    A."native" = "%NATIVE%";
    A."@" =      "%NATIVE%";
    NS."@" = [
      "ns1.uninsane.org."
      "ns2.uninsane.org."
      "ns3.uninsane.org."
    ];
  };

  sane.services.trust-dns.zones."uninsane.org".file =
    "/var/lib/trust-dns/uninsane.org.zone";

  systemd.services.trust-dns.preStart = let
    sed = "${pkgs.gnused}/bin/sed";
    zone-dir = "/var/lib/trust-dns";
    zone-out = "${zone-dir}/uninsane.org.zone";
    zone-template = pkgs.writeText "uninsane.org.zone.in" config.sane.services.trust-dns.generatedZones."uninsane.org";
  in ''
    # make WAN records available to trust-dns
    mkdir -p ${zone-dir}
    ip=$(cat '${config.sane.services.dyn-dns.ipPath}')
    ${sed} s/%NATIVE%/$ip/ ${zone-template} > ${zone-out}
  '';

  sane.services.dyn-dns.restartOnChange = [ "trust-dns.service" ];
}
