{ dnsData, ... }:
let
  inherit (dnsData) propA;
in
{
  vacu.ns.vanity = 4;
  A = propA;
  subdomains = {
    admin.A = propA;
    matrix.A = propA;
  };
}
