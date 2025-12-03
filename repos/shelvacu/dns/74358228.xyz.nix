{ dnsData, ... }:
let
  inherit (dnsData) propA;
in
{
  vacu.liamMail = false;
  vacu.defaultCAA = true;
  A = propA;
  subdomains = {
    www.A = propA;
    dyn.NS = [
      "pns51.cloudns.net."
      "pns52.cloudns.net."
      "pns53.cloudns.net."
      "pns54.cloudns.net."
    ];
    test.TXT = [ "aaaaaa" ];
  };
}
