{ dnsData, ... }:
let
  inherit (dnsData) doA;
in
{
  vacu.liamMail = true;

  subdomains = {
    # keep-sorted start block=yes
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
    # keep-sorted end
  };
}
