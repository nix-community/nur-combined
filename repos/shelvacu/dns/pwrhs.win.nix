{ dnsData, ... }:
let
  inherit (dnsData) propA;
in
{
  vacu.defaultCAA = true;
  A = propA;
  subdomains.habitat.A = propA;
}
