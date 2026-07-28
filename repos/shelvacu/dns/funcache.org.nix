{ dnsData, ... }:
let
  inherit (dnsData) solisA;
in
{
  vacu.ns.vanity = 8;
  vacu.liamMail = true;
  A = solisA;
  subdomains.www.A = solisA;
}
