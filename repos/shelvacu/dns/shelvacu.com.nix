{
  dns,
  dnsData,
  lib,
  vaculib,
  outerConfig,
  ...
}:
let
  s = v: [ v ];
  inherit (dns.lib.combinators) host;
  inherit (dnsData) propA solisA doA cloudns;
  # which domains to allow dmarc reports.
  # ex: _dmarc.dis8.net TXT has "rua=rua-reports@shelvacu.com", reports will only be sent if shelvacu.com allows them
  # allow all domains configured in this repo, and one level of subdomain (ideally all but thats hard, this should be good enough)
  allow_report_domains = lib.pipe outerConfig.vacu.dns [
    lib.attrNames
    (
      list:
      list
      ++ [
        "theviolincase.com"
        "violingifts.com"
      ]
    )
    (lib.concatMap (domain: [
      domain
      "*.${domain}"
    ]))
  ];
in
{
  vacu.liamMail = true;
  A = propA;
  subdomains = {
    _atproto.TXT = s "did=did:plc:oqenurzqeji6ulii3myxls64";
    "_report._dmarc".subdomains = vaculib.mapNamesToAttrsConst {
      TXT = s "v=DMARC1";
    } allow_report_domains;
    "2e14".A = propA;
    f.A = propA;
    files.A = propA;
    copy.A = propA;
    copyparty.A = propA;
    actual.A = propA;
    autoconfig.A = doA;
    awoo.A = s "45.142.157.71";
    dav-experiment.A = propA;
    dynrecords.NS = dnsData.cloudnsNS;
    ft.subdomains = {
      "*".A = s "45.87.250.193";
      _acme-challenge.CNAME = s "17aa43aa-9295-4522-8cf2-b94ba537753d.auth.acme-dns.io.";
    };
    id.A = propA;
    imap.A = doA;
    jf.A = propA;
    jelly.A = propA;
    jellyfin.A = propA;
    jobs.A = propA;
    mail.A = doA;
    matrix.A = propA;
    mumble.A = propA;
    nitter.A = propA;
    nixcache.A = propA;
    ns1 = host cloudns.pns51.ipv4 cloudns.pns51.ipv6;
    ns2 = host cloudns.pns52.ipv4 cloudns.pns52.ipv6;
    ns3 = host cloudns.pns53.ipv4 cloudns.pns53.ipv6;
    ns4 = host cloudns.pns54.ipv4 cloudns.pns54.ipv6;
    powerhouse.CNAME = s "powerhouse.dyn.74358228.xyz.";
    prop.CNAME = s "prophecy";
    prophecy.A = propA;
    prophecy.subdomains."*".A = propA;
    "*.prophecy".A = propA;
    "s3.garage.prophecy".A = propA;
    "admin.garage.prophecy".A = propA;
    radicale.A = propA;
    servacu.A = s "167.99.161.174";
    smtp.A = doA;
    sol.CNAME = s "solis";
    solis.A = solisA;
    "*.solis".A = solisA;
    vaultwarden.A = propA;
    www.A = propA;
    xs.A = solisA;
  };
}
