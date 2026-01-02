{
  dns,
  dnsData,
  lib,
  ...
}:
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
    # shelvacumiraspet.a.ns.74358228.xyz.
    # shelvacumiraspet.b.ns.74358228.xyz.
    # ...
    ns.subdomains = lib.mapAttrs' (
      letter: info: lib.nameValuePair "*.${letter}" (dns.lib.combinators.host info.ipv4 info.ipv6)
    ) letterToInfo;
    "jean-lucorg.e.ns" = {
      A = [ "69.65.50.194" ];
      # ns1.afraid.org has no ipv6
    };
    "jean-lucorg.f.ns" = {
      A = [ "69.65.50.223" ];
      AAAA = [ "2001:1850:1:5:800::6b" ];
    };
    "jean-lucorg.g.ns" = {
      A = [ "67.220.81.190" ];
      # ns3.afraid.org has no ipv6
    };
    "jean-lucorg.h.ns" = {
      A = [ "70.39.97.253" ];
      AAAA = [ "2610:150:bddb:d271::2" ];
    };
  };
}
