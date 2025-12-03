{ dnsData, ... }:
let
  inherit (dnsData) propA;
in
{
  # this domain is ded; only used to display ded message
  vacu.liamMail = false;
  vacu.defaultCAA = true;
  A = propA;
  subdomains.www.A = propA;
}
