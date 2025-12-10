{ dnsData, ... }:
let
  inherit (dnsData) doA;
in
{
  vacu.liamMail = true;

  subdomains = {
    do-a.A = doA;
    liam = {
      A = doA;
      vacu.liamMail = true;
    };
    mail = {
      A = doA;
      vacu.liamMail = true;
    };
    solis.A = dnsData.solisA;
  };
}
