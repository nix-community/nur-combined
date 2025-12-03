{ dnsData, ... }:
let
  inherit (dnsData) propA;
in
{
  vacu.defaultCAA = true;
  A = propA;
  subdomains = {
    "git".A = propA;
    "auth".A = propA;
    "wisdom".A = propA;
    "chat" =
      {
        vacu.liamMail = true;
        A = propA;
      };
    "gabriel-dropout".A = propA;
  };
}
