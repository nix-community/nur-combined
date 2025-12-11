{ dns, dnsData, lib, ... }:
let
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
