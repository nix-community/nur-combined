{ dnsData, lib, ... }:
let
  s = x: [ x ];
  inherit (dnsData) propA;
  defaultNsSubdomains = lib.mkDefault {
      a.CNAME = s "pns51.cloudns.net.";
      b.CNAME = s "pns52.cloudns.net.";
      c.CNAME = s "pns53.cloudns.net.";
      d.CNAME = s "pns54.cloudns.net.";
      e.CNAME = s "pns51.cloudns.net.";
      f.CNAME = s "pns52.cloudns.net.";
      g.CNAME = s "pns53.cloudns.net.";
      h.CNAME = s "pns54.cloudns.net.";
    };
in
{
  vacu.liamMail = false;
  A = propA;
  subdomains = {
    www.A = propA;
    dyn.NS = dnsData.cloudnsNameServers;
    "*.*.ns".subdomains = defaultNsSubdomains;
    "*.*.*.ns".subdomains = defaultNsSubdomains;
    "*.*.*.*.ns".subdomains = defaultNsSubdomains;
  };
}
