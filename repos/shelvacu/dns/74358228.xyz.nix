{ dns, dnsData, lib, ... }:
let
  s = x: [ x ];
  inherit (dnsData) propA cloudns;
  letterToInfo = {
    a = cloudns.pns51;
    b = cloudns.pns52;
    c = cloudns.pns53;
    d = cloudns.pns54;
    e = cloudns.pns51;
    f = cloudns.pns52;
    g = cloudns.pns53;
    h = cloudns.pns54;
  };
  # defaultNsSubdomains = lib.mkDefault {
  #     a.CNAME = s "pns51.cloudns.net.";
  #     b.CNAME = s "pns52.cloudns.net.";
  #     c.CNAME = s "pns53.cloudns.net.";
  #     d.CNAME = s "pns54.cloudns.net.";
  #     e.CNAME = s "pns51.cloudns.net.";
  #     f.CNAME = s "pns52.cloudns.net.";
  #     g.CNAME = s "pns53.cloudns.net.";
  #     h.CNAME = s "pns54.cloudns.net.";
  #   };
in
{
  vacu.liamMail = false;
  A = propA;
  subdomains = {
    www.A = propA;
    dyn.NS = dnsData.cloudnsNS;
    # this allows settings the nameservers for (eg) shelvacu.miras.pet to:
    # shelvacu.miras.pet.a.ns.74358228.xyz.
    # shelvacu.miras.pet.b.ns.74358228.xyz.
    # ...
    ns.subdomains = lib.mapAttrs' (letter: info: 
      lib.nameValuePair "*.${letter}" (dns.lib.combinators.host info.ipv4 info.ipv6)
    ) letterToInfo;
  };
}
