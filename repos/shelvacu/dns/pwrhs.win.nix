{ dnsData, ... }:
let
  inherit (dnsData) propA;
in
{
  vacu.ns.vanity = 6;
  A = propA;
  subdomains.habitat.A = propA;
}
