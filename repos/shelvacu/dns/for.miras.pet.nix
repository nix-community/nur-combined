{ dnsData, ... }:
let
  inherit (dnsData) propA;
in
{
  A = propA;
  subdomains = {
    "git".A = propA;
    "auth".A = propA;
    "wisdom".A = propA;
    "chat" = {
      vacu.liamMail = true;
      A = propA;
    };
    "gabriel-dropout".A = propA;
  };
}
