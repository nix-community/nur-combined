{ dnsData, ... }:
let
  inherit (dnsData) propA;
in
{
  vacu.ns.vanityShelvacu = true;
  A = propA;
  subdomains = {
    # keep-sorted start block=yes
    "auth".A = propA;
    "chat" = {
      vacu.liamMail = true;
      A = propA;
    };
    "gabriel-dropout".A = propA;
    "git".A = propA;
    "wisdom".A = propA;
    # keep-sorted end
  };
}
