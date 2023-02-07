let group = import ../groups/dns.nix;
in {
  name = "dnsmasq";
  uid = 2004;
  inherit group;
  extraGroups = [ ];
}
