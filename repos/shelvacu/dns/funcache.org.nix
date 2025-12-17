{ dnsData, ... }:
let
  inherit (dnsData) solisA;
in
{
  vacu.liamMail = true;
  A = solisA;
  subdomains.www.A = solisA;
}
