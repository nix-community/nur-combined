{ dnsData, ... }:
let
  inherit (dnsData) propA;
in
{
  A = propA;
  subdomains.habitat.A = propA;
}
