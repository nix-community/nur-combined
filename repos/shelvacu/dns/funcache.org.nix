{ dnsData, ... }:
let
  inherit (dnsData) solisA;
in
{
  vacu.ns.vanity = 8;
  vacu.liamMail = true;
  A = solisA;
  subdomains = {
    "mailjet._8bc711db".TXT = [ "8bc711db3497fe1c140c108c8261bb2a" ];
    www.A = solisA;
  };
}
