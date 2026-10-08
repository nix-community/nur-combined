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
    "mailjet._ca9a9141".TXT = [ "ca9a9141fbcef14f87d740cdc1f06c4e" ];
  };
}
