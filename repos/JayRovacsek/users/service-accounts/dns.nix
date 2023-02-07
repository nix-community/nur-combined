let group = import ../groups/dns.nix;
in {
  name = "dns";
  uid = 2005;
  inherit group;
  extraGroups = [ ];
}
